# AWS Tools

## S3cmd

[Official s3cmd repo](https://github.com/s3tools/s3cmd) -- Command line tool for managing Amazon S3 and CloudFront services

為 S3 Bucket 內所有檔案添加 `Cache-Contorl` 設定：

```bash
$ s3cmd --recursive --add-header="Cache-Control:max-age=31536000" modify s3://BUCKET_NAME
```
