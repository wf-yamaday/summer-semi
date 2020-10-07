# Demo-App

> 参考：https://guides.gradle.org/building-java-web-applications/

*本演習はJava 1.8系で動作するので注意*

Javaのバージョン切り替えについては以下を参照．

- [Windows向け](https://github.com/HazeyamaLab/setup/issues/1)
- [macOS向け](https://github.com/HazeyamaLab/setup/issues/6)

## JavaによるWebアプリケーションの作成

今回は最低限のディレクトリとファイルを作成済みです．

```
├── build.gradle
├── settings.gradle
└── src
    ├── main
    │   ├── java
    │   │   └── jp
    │   │       └── ac
    │   │           └── gakugei
    │   │               └── hazelab
    │   │                   └── demo
    │   │                       └── HelloServlet.java
    │   ├── resources
    │   └── webapp
    │       ├── index.html
    │       └── response.jsp
    └── test
        ├── java
        │   └── jp
        │       └── ac
        │           └── gakugei
        │               └── hazelab
        │                   └── demo
        │                       └── HelloServletTest.java
        └── resources
```

## Gradleの設定とGradle wrapperの作成

`build.gradle`を以下のように編集します．

```gradle
plugins {
    id 'war'
}

repositories {
    jcenter()
}

dependencies {
    providedCompile 'javax.servlet:javax.servlet-api:3.1.0'
    testCompile 'junit:junit:4.12'
}
```

Gradle wrapperを作成します．

```bash
gradle wrapper --gradle-version=4.10.3
```

### Servletの作成

`demo-app/src/main/java/jp/ac/gakugei/hazelab/demo/HelloServlet.java`を以下のように編集します．


```java
package jp.ac.gakugei.hazelab.demo;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "HelloServlet", urlPatterns = { "hello" }, loadOnStartup = 1)
public class HelloServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.getWriter().print("Hello, World!");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        if (name == null)
            name = "World";
        request.setAttribute("user", name);
        request.getRequestDispatcher("response.jsp").forward(request, response);
    }
}
```

`demo-app/src/main/webapp/index.html`を編集します．

```html
<html>
  <head>
    <title>Web Demo</title>
  </head>
  <body>
    <p>Say <a href="hello">Hello</a></p>

    <form method="post" action="hello">
      <h2>Name:</h2>
      <input type="text" id="say-hello-text-input" name="name" />
      <input type="submit" id="say-hello-button" value="Say Hello" />
    </form>
  </body>
</html>
```

`demo-app/src/main/webapp/response.jsp`を編集します．

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title>Hello Page</title>
  </head>
  <body>
    <h2>Hello, ${user}!</h2>
  </body>
</html>
```



### Grettyプラグインの追加

ServletコンテナをGradleで立ち上げるプラグインの一つ．

https://github.com/akhikhl/gretty

`build.gradle`を以下のように編集します．

```gradle
plugins {
    id 'war'
    id 'org.gretty' version '2.2.0'
}

repositories {
    jcenter()
}

dependencies {
    providedCompile 'javax.servlet:javax.servlet-api:3.1.0'
    testCompile 'junit:junit:4.12'
}
```


## 単体テスト

単体テストとは，個々のユニットが仕様を満たしているかをテストする手法です．
Javaのようなオブジェクト指向プログラミングでは，ユニットはメソッドであることが多いです．

`build.gradle`を編集します．

```gradle
plugins {
    id 'war'
    id 'org.gretty' version '2.2.0'
}

repositories {
    jcenter()
}

dependencies {
    providedCompile 'javax.servlet:javax.servlet-api:3.1.0'
    testCompile 'junit:junit:4.12'
    testCompile 'org.mockito:mockito-core:2.7.19'
}

```

`demo-app/src/test/java/jp/ac/gakugei/hazelab/demo/HelloServletTest.java`を編集します．

```java
package jp.ac.gakugei.hazelab.demo;

import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import javax.servlet.RequestDispatcher;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.io.StringWriter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.*;

public class HelloServletTest {
    @Mock
    private HttpServletRequest request;
    @Mock
    private HttpServletResponse response;
    @Mock
    private RequestDispatcher requestDispatcher;

    @Before
    public void setUp() throws Exception {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void doGet() throws Exception {
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);

        when(response.getWriter()).thenReturn(printWriter);

        new HelloServlet().doGet(request, response);

        assertEquals("Hello, World!", stringWriter.toString());
    }

    @Test
    public void doPostWithoutName() throws Exception {
        when(request.getRequestDispatcher("response.jsp")).thenReturn(requestDispatcher);

        new HelloServlet().doPost(request, response);

        verify(request).setAttribute("user", "World");
        verify(requestDispatcher).forward(request, response);
    }

    @Test
    public void doPostWithName() throws Exception {
        when(request.getParameter("name")).thenReturn("Dolly");
        when(request.getRequestDispatcher("response.jsp")).thenReturn(requestDispatcher);

        new HelloServlet().doPost(request, response);

        verify(request).setAttribute("user", "Dolly");
        verify(requestDispatcher).forward(request, response);
    }
}
```