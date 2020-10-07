# DemoApp

## 環境

- java 1.8
- Gradle 6系

**本演習はJava 1.8系で動作するので注意**

Javaのバージョン切り替えについては以下を参照．

- [Windows向け](https://github.com/HazeyamaLab/setup/issues/1)
- [macOS向け](https://github.com/HazeyamaLab/setup/issues/6)

`java -version`コマンドで1.8系であることを確認してください．

```bash
java -version
openjdk version "1.8.0_265"
OpenJDK Runtime Environment (AdoptOpenJDK)(build 1.8.0_265-b01)
OpenJDK 64-Bit Server VM (AdoptOpenJDK)(build 25.265-b01, mixed mode)
```

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

## 1. build.Gradleの設定とGradle wrapperの作成

はじめに`build.gradle`で依存関係の設定などを行います．  
具体的には`build.gradle`を以下のように編集します．

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

次にGradle wrapperを作成します．  
Gradle wrapperを作成しておくと，Gradleがインストールされていない環境でもスクリプトを利用して動作させることができます．  
以下のコマンドで作成することができます．

```bash
gradle wrapper --gradle-version=4.10.3
```

コマンド実行後に`gradlew`と`gradlew.bat`の2つが作成されているはずです．  
また`gradle/wrapper`ディレクトリ配下に`gradle-wrapper.jar`と`gradle-wrapper.properties`の2つのファイルが作成されています．

## 2. HelloServlet，index.html，response.jspの作成

### 2.1 HelloServletの作成

JavaでHTTPリクエストを処理するServletを作成します．  
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

### 2.2 index.htmlの作成

次にウェルカムファイルである`index.html`を作成します．  
`index.html`は先ほど作成した`HelloServlet`に対してPOSTリクエストでフォームを送信する画面にします．  
`demo-app/src/main/webapp/index.html`を以下のように編集します．

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

### 2.2 response.jspの作成

`response.jsp`は`HelloServlet`でPOSTリクエストを処理した後に遷移する画面になります．  
`demo-app/src/main/webapp/response.jsp`を以下のように編集します．

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

## 3. Grettyプラグインの追加

Servlet，JSPなどを作成しましたがServletを実行する環境であるWebコンテナ(Servletコンテナ)が無いので，アプリケーションを動作させることができません．  
そこでServletコンテナをGradleで立ち上げるプラグインの一つであるGettyを導入します．

> 参考：Gretty, https://github.com/akhikhl/gretty

導入は`build.gradle`pluginsに追記するだけです．  
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

`build.gradle`を編集後にgradleのタスクを確認すると，Gretty tasks の項目が増えていることが確認できます．  
gradleのtasksの確認は以下のコマンドで行います．

```bash
./gradlew tasks
```

## 4. アプリケーションの実行

今回は Gretty tasksの`appRun`を使用してWebコンテナ(Servletコンテナ)を立ち上げます．

```bash
./gradlew appRun
```

起動に成功すると，http://localhost:8080/demo-app/ で`index.html`を確認することができます．

`index.html`のフォームから文字列を送信してWebアプリケーションの動作を確認してみましょう．


## 5. 単体テスト

単体テストとは，個々のユニットが仕様を満たしているかをテストする手法です．
Javaのようなオブジェクト指向プログラミングでは，ユニットはメソッドであることが多いです．

今回のようなHTTPリクエストを受けて処理をするような外部の要求に依存するメソッドでは単体テストの記述が難しいです．
そこで **Mock(モック)** を利用して単体テストを記述します．

テストコードでMockを簡単に利用するために，Mockito を導入します．

> Mockito, https://site.mockito.org/

導入は`build.gradle`のdependenciesに追記するだけです．  
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
    testCompile 'org.mockito:mockito-core:2.7.19'
}

```

次にテストコードの`demo-app/src/test/java/jp/ac/gakugei/hazelab/demo/HelloServletTest.java`を編集します．

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

記述後にテストを実行してみましょう．

```bash
./gradlew test
```

テストの結果はレポートとして`build/reports/tests/test/index.html`に出力されます．


## 参考資料

- Building Java Web Applications, https://guides.gradle.org/building-java-web-applications/
