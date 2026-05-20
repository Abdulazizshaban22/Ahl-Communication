import os, json, boto3, logging, datetime
logger = logging.getLogger()
logger.setLevel(logging.INFO)

WAFv2 = boto3.client('wafv2', region_name='us-east-1')  # CloudFront scope fixed region
REGIONAL = boto3.client('wafv2')

def _switch_group_actions(acl, scope):
    rules = acl['Rules']
    changed = False
    for r in rules:
        st = r.get('Statement', {})
        mrg = st.get('ManagedRuleGroupStatement')
        if not mrg: 
            continue
        name = mrg.get('Name')
        vendor = mrg.get('VendorName')
        # Only flip overrides that explicitly COUNT to default (none) => use group's internal action (often block)
        override = r.get('OverrideAction')
        if override and 'Count' in override:
            logger.info(f"Flipping rule {name} ({vendor}) from COUNT to default")
            r['OverrideAction'] = {'None': {}}
            changed = True
    return changed, rules

def handler(event, context):
    cf_acl_arn = os.environ.get('CF_WEB_ACL_ARN')
    alb_acl_arn = os.environ.get('ALB_WEB_ACL_ARN')
    enable = os.environ.get('ENABLE_AUTO_BLOCK', 'true').lower() == 'true'

    if not enable:
        logger.info("AUTO BLOCK disabled — exiting.")
        return {"status":"disabled"}

    out = {}
    if cf_acl_arn:
        acl = WAFv2.get_web_acl(Name=cf_acl_arn.split('/')[-1], Scope='CLOUDFRONT', Id=cf_acl_arn.split('/')[-2])
        lock = acl['LockToken']
        changed, new_rules = _switch_group_actions(acl['WebACL'], 'CLOUDFRONT')
        if changed:
            res = WAFv2.update_web_acl(
                Name=acl['WebACL']['Name'],
                Scope='CLOUDFRONT',
                Id=acl['WebACL']['Id'],
                DefaultAction=acl['WebACL']['DefaultAction'],
                Rules=new_rules,
                VisibilityConfig=acl['WebACL']['VisibilityConfig'],
                LockToken=lock
            )
            out['cloudfront'] = "updated"
        else:
            out['cloudfront'] = "no-change"

    if alb_acl_arn:
        # regional updates require region-specific WAFv2; using default client
        name = alb_acl_arn.split('/')[-1]
        id_ = alb_acl_arn.split('/')[-2]
        acl = REGIONAL.get_web_acl(Name=name, Scope='REGIONAL', Id=id_)
        lock = acl['LockToken']
        changed, new_rules = _switch_group_actions(acl['WebACL'], 'REGIONAL')
        if changed:
            REGIONAL.update_web_acl(
                Name=acl['WebACL']['Name'],
                Scope='REGIONAL',
                Id=acl['WebACL']['Id'],
                DefaultAction=acl['WebACL']['DefaultAction'],
                Rules=new_rules,
                VisibilityConfig=acl['WebACL']['VisibilityConfig'],
                LockToken=lock
            )
            out['regional'] = "updated"
        else:
            out['regional'] = "no-change"

    return {"status":"ok", "result":out}
