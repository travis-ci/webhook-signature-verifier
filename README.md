# WebhookSignatureVerifier

A small Sinatra app to verify the webhook payload signature

## Description

Travis CI's [webhook notification](https://docs.travis-ci.com/user/notifications/#Webhook-notification)
delivers a POST request to the specified endpoint a JSON payload as
described.

In addition, the request comes with the custom HTTP header `Signature`
for the `payload` data.

This small Sinatra app shows how to verify the signature.

## Verifying the signature

1. Pick up the `payload` data from the HTTP request's body.
1. Obtain the `Signature` header value
1. Obtain the public key corresponding to the private key that signed the
  payload. This is available at the `/config` endpoint's `config.notifications.webhook.public_key`.
1. Verify the signature using the public key and SHA1 digest.