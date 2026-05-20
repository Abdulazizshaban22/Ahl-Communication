import fetch from 'node-fetch';

const JIRA_URL = process.env.JIRA_URL; // e.g., https://your-domain.atlassian.net
const JIRA_EMAIL = process.env.JIRA_EMAIL;
const JIRA_API_TOKEN = process.env.JIRA_API_TOKEN;
const JIRA_PROJECT_KEY = process.env.JIRA_PROJECT_KEY || "OPS";

const SLACK_WEBHOOK = process.env.SLACK_WEBHOOK || "";
const NOTION_TOKEN = process.env.NOTION_TOKEN || "";
const NOTION_PARENT = process.env.NOTION_PARENT || ""; // page_id or database_id

function basicAuth(email, token) {
  return 'Basic ' + Buffer.from(`${email}:${token}`).toString('base64');
}

async function createJiraIssue(summary, description) {
  const url = `${JIRA_URL}/rest/api/3/issue`;
  const body = {
    fields: {
      project: { key: JIRA_PROJECT_KEY },
      summary,
      issuetype: { name: "Incident" },
      description: { type: "doc", version: 1, content: [{ type: "paragraph", content: [{ type: "text", text: description }]}] }
    }
  };
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Authorization': basicAuth(JIRA_EMAIL, JIRA_API_TOKEN),
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Jira create issue failed: ${res.status} ${text}`);
  }
  return res.json();
}

async function sendSlack(text) {
  if (!SLACK_WEBHOOK) return;
  await fetch(SLACK_WEBHOOK, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ text })
  });
}

async function createNotion(summary, description) {
  if (!NOTION_TOKEN || !NOTION_PARENT) return;
  const res = await fetch('https://api.notion.com/v1/pages', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${NOTION_TOKEN}`,
      'Notion-Version': '2022-06-28',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      parent: { page_id: NOTION_PARENT },
      properties: {
        title: { title: [{ text: { content: summary } }] }
      },
      children: [{
        object: 'block',
        type: 'paragraph',
        paragraph: { rich_text: [{ type: 'text', text: { content: description } }] }
      }]
    })
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Notion create page failed: ${res.status} ${text}`);
  }
  return res.json();
}

export const handler = async (event) => {
  // SNS event with CloudWatch Alarm JSON in message
  const records = event.Records || [];
  for (const r of records) {
    const msg = JSON.parse(r.Sns.Message);
    const alarm = msg.AlarmName || msg.alarmName || "Ahla Alarm";
    const reason = msg.NewStateReason || msg.reason || JSON.stringify(msg);
    const summary = `SLO Burn-Rate Alert: ${alarm}`;
    const description = `State: ${msg.NewStateValue || msg.state}
Reason: ${reason}
Region: ${msg.Region || msg.region || ''}
Link: ${msg.AlarmUrl || ''}`;

    try {
      const jira = await createJiraIssue(summary, description);
      await sendSlack(`:rotating_light: ${summary}
${reason}
Jira: ${JIRA_URL}/browse/${jira.key}`);
      await createNotion(summary, description);
    } catch (e) {
      await sendSlack(`:warning: Failed to create Jira/Notion for ${alarm}: ${e.message}`);
      console.error(e);
    }
  }
  return { ok: true };
};
