# XSS (Cross Site Scripting) Prevention Cheat Sheet

原文：https://www.owasp.org/index.php/XSS_(Cross_Site_Scripting)_Prevention_Cheat_Sheet

## 2. XSS 防護規則

### 規則 #0 - 除非在允許的位置，不然永不插入不信任的資料

第一條規則是*拒絕所有* - 不要將不信任的資料放進你的 HTML，除非它屬於規則 #1 至規則 #5 之中定義的其中一個位置。原因是，在 HTML 中充斥著太多奇怪的上下文，會使得轉譯規則表變得非常複雜。
我們想不到任何理由將不信任的資料放在那些上下文之中。這包含“巢狀的上下文”（nested contexts），例如在 javascript 中的 URL -- 在這些位置的編碼規則是非常棘手且危險的。
如果你堅持將不信任的資料放進巢狀的上下文中。請做大量的跨瀏覽器測試，並讓我們知道你發現了什麼。

```html
 <script>...NEVER PUT UNTRUSTED DATA HERE...</script>   directly in a script
 
 <!--...NEVER PUT UNTRUSTED DATA HERE...-->             inside an HTML comment
 
 <div ...NEVER PUT UNTRUSTED DATA HERE...=test />       in an attribute name
 
 <NEVER PUT UNTRUSTED DATA HERE... href="/test" />      in a tag name
 
 <style>...NEVER PUT UNTRUSTED DATA HERE...</style>     directly in CSS
```

最重要的是，永遠不要接受並執行從不信任來源傳遞過來的程式碼。例如，一個名為 callback 的參數，它包含一個 JavaScript 程式碼片段，沒有任何逸出方法（escaping）可以解決這個問題。

