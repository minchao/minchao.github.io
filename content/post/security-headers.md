# Security Headers

## Headers

### Content-Security-Policy (CSP)

- [MDN - Content Security Policy (CSP)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [Content Security Policy (CSP) - Quick Reference Guide](https://content-security-policy.com/)

### Strict-Transport-Security

https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security

### Referrer-Policy

https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy

### X-Content-Type-Options

https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options

### X-Frame-Options

https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options

### X-XSS-Protection

https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection

參考 [MDN 的說明](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection) ，由於 XSS Auditor 存在許多問題，現代瀏覽器多已放棄支援，推薦使用 CSP 防護您的網站。

> if you do not need to support legacy browsers, it is recommended that you use Content-Security-Policy without allowing unsafe-inline scripts instead.

關於本設定的更多討論，可參考 helmet issue 230: [X-XSS-Protection: header should be disabled by default](https://github.com/helmetjs/helmet/issues/230)。

### Permissions-Policy

- https://www.w3.org/TR/permissions-policy/

## Tools

- [Security Headers](https://securityheaders.com/)
- Google [CSP Evaluator](https://csp-evaluator.withgoogle.com/)
- Mozilla [Observatory](https://observatory.mozilla.org)
- [HELMET](https://github.com/helmetjs/helmet) - Express.js security with HTTP headers.
