# Push Apdex to CloudWatch (Node.js)

```js
import { CloudWatchClient, PutMetricDataCommand } from "@aws-sdk/client-cloudwatch";

const cw = new CloudWatchClient({ region: process.env.AWS_REGION });
const T = Number(process.env.APDEX_T || 0.2); // seconds

export async function recordApdex(service, samples) {
  // samples: array of response times (seconds)
  const satisfied = samples.filter(s => s <= T).length;
  const tolerating = samples.filter(s => s > T && s <= 4*T).length;
  const total = samples.length || 1;
  const apdex = (satisfied + 0.5 * tolerating) / total;

  await cw.send(new PutMetricDataCommand({
    Namespace: `Ahla/${service}`,
    MetricData: [{
      MetricName: "Apdex",
      Dimensions: [{ Name: "Service", Value: service }],
      Timestamp: new Date(),
      Value: apdex,
      Unit: "None"
    }]
  }));
}
```
