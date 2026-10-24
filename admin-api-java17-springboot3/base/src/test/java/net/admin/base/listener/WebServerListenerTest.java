package net.admin.base.listener;

import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.core.LogEvent;
import org.apache.logging.log4j.core.Logger;
import org.apache.logging.log4j.core.appender.AbstractAppender;
import org.apache.logging.log4j.core.config.Property;
import org.apache.logging.log4j.core.layout.PatternLayout;
import org.junit.jupiter.api.Test;
import org.springframework.boot.web.server.WebServer;
import org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext;
import org.springframework.boot.web.servlet.context.ServletWebServerInitializedEvent;
import org.springframework.mock.env.MockEnvironment;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class WebServerListenerTest {

    @Test
    void printsBannerOnceInTheSameLogEntryBeforeStartupDetails() {
        List<String> messages = new ArrayList<>();
        AbstractAppender appender = new AbstractAppender("startup-check", null, PatternLayout.createDefaultLayout(), false, Property.EMPTY_ARRAY) {
            @Override
            public void append(LogEvent event) {
                messages.add(event.getMessage().getFormattedMessage());
            }
        };
        Logger logger = (Logger) LogManager.getLogger(WebServerListener.class);
        Level previousLevel = logger.getLevel();
        appender.start();
        logger.addAppender(appender);
        logger.setLevel(Level.WARN);
        try (ServletWebServerApplicationContext context = new ServletWebServerApplicationContext()) {
            context.setEnvironment(new MockEnvironment()
                    .withProperty("project.name", "admin")
                    .withProperty("spring.profiles.active", "dev")
                    .withProperty("server.servlet.context-path", "/"));
            WebServer server = mock(WebServer.class);
            when(server.getPort()).thenReturn(1024);

            new WebServerListener().onApplicationEvent(new ServletWebServerInitializedEvent(server, context));

            assertEquals(1, messages.size());
            String message = messages.get(0).replaceAll("\\x1B\\[[0-9;]*m", "").replace("\r\n", "\n");
            int bannerEnd = message.indexOf("你错过的晚霞、失约的晚餐、没牵到的手，才是永远无法补录的人生正文。");
            int title = message.indexOf("-------------【admin】 服务已成功启动");
            assertTrue(bannerEnd >= 0 && title > bannerEnd);
            String closingSentence = "你错过的晚霞、失约的晚餐、没牵到的手，才是永远无法补录的人生正文。";
            assertEquals("\n\n", message.substring(bannerEnd + closingSentence.length(), title));
            String artwork = message.substring(0, message.indexOf("人生是用看见花开")).strip();
            assertFalse(artwork.isBlank());
            assertTrue(artwork.lines().count() <= 18);
            assertTrue(artwork.lines().allMatch(line -> line.length() <= 42));
            assertEquals(message.indexOf(artwork), message.lastIndexOf(artwork));
            assertTrue(StandardCharsets.US_ASCII.newEncoder().canEncode(artwork));
            assertTrue(message.contains("人生是用看见花开、听见雨声的瞬间拼凑的。"));
            assertFalse(message.contains("(o)(o)"));
            assertFalse(message.contains("山里灵活的狗"));
            assertFalse(message.contains("/^-----^\\"));
            assertTrue(message.indexOf("当前启动环境:") > title);
            assertTrue(message.contains("http://localhost:1024/swagger-ui/index.html"));
            assertFalse(message.contains("${AnsiColor."));
        } finally {
            logger.removeAppender(appender);
            logger.setLevel(previousLevel);
            appender.stop();
        }
    }
}
