# Lambda GeoIP Layer (MaxMind GeoLite2)
1) Create a MaxMind account, download **GeoLite2-City.mmdb** (accept EULA).
2) Put the file in `lambda/geoip_layer/GeoLite2-City.mmdb`.
3) Build the layer zip:
```bash
bash lambda/geoip_layer/build_layer.sh python3.12
```
4) Publish the layer in Lambda and note the LayerVersionArn.
5) Set `lambda_geoip_layer_arn` in Terraform and attach it to the ALB logs Lambda.
