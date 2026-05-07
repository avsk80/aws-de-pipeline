import json
import os
import boto3

s3 = boto3.client("s3")


def lambda_handler(event, context):
    processed_bucket = os.environ["PROCESSED_BUCKET"]

    for record in event["Records"]:
        raw_bucket = record["s3"]["bucket"]["name"]
        raw_key = record["s3"]["object"]["key"]

        print(f"Received file: s3://{raw_bucket}/{raw_key}")

        output_key = raw_key.replace("incoming/", "processed/").replace(".csv", ".parquet")

        s3.put_object(
            Bucket=processed_bucket,
            Key=output_key,
            Body=b"placeholder parquet content"
        )

        print(f"Wrote output file: s3://{processed_bucket}/{output_key}")

    return {
        "statusCode": 200,
        "body": json.dumps("Processing complete")
    }