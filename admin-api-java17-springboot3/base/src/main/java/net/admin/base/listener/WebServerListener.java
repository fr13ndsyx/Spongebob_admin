package net.admin.base.listener;

import cn.hutool.core.net.NetUtil;
import cn.hutool.core.util.URLUtil;
import lombok.extern.slf4j.Slf4j;
import net.admin.base.common.code.ErrorCodeRegister;
import net.admin.base.common.enumeration.SystemEnvironmentEnum;
import net.admin.base.common.util.EnumUtil;
import org.springframework.boot.ResourceBanner;
import org.springframework.boot.web.context.WebServerApplicationContext;
import org.springframework.boot.web.context.WebServerInitializedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.core.annotation.Order;
import org.springframework.core.env.Environment;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;

@Slf4j
@Component
@Order(value = 1024)
public class WebServerListener implements ApplicationListener<WebServerInitializedEvent> {



    @Override
    public void onApplicationEvent(WebServerInitializedEvent webServerInitializedEvent) {
        // 项目信息
        showProjectMessage(webServerInitializedEvent);
    }

    /**
     * 显示项目信息
     */
    private void showProjectMessage(WebServerInitializedEvent webServerInitializedEvent) {
        WebServerApplicationContext context = webServerInitializedEvent.getApplicationContext();
        Environment env = context.getEnvironment();

        //获取服务信息
        String ip = NetUtil.getLocalhost().getHostAddress();
        Integer port = webServerInitializedEvent.getWebServer().getPort();
        String contextPath = env.getProperty("server.servlet.context-path");
        if (contextPath == null) {
            contextPath = "";
        }
        String profile = env.getProperty("spring.profiles.active");
        SystemEnvironmentEnum environmentEnum = EnumUtil.getEnumByValue(profile, SystemEnvironmentEnum.class);
        String projectName = env.getProperty("project.name");
        //拼接服务地址
        String title = String.format("-------------【%s】 服务已成功启动 （%s started successfully）-------------", projectName, projectName);

        // 初始化状态码
        int codeCount = ErrorCodeRegister.initialize();
        String localhostUrl = URLUtil.normalize(String.format("http://localhost:%d%s", port, contextPath), false, true);
        String externalUrl = URLUtil.normalize(String.format("http://%s:%d%s", ip, port, contextPath), false, true);
        String swaggerUrl = URLUtil.normalize(String.format("http://localhost:%d%s/swagger-ui/index.html", port, contextPath), false, true);
        ByteArrayOutputStream bannerOutput = new ByteArrayOutputStream();
        try (PrintStream bannerStream = new PrintStream(bannerOutput, false, StandardCharsets.UTF_8)) {
            new ResourceBanner(new ClassPathResource("banner.txt")).printBanner(env, getClass(), bannerStream);
        }
        log.warn("\n{}{}\n" +
                        "\t当前启动环境:\t{} , {}" +
                        "\n\t返回码初始化:\t完成{}个返回码初始化" +
                        "\n\t服务本机地址:\t{}" +
                        "\n\t服务外网地址:\t{}" +
                        "\n\tSwagger地址:\t{}" +
                        "\n-------------------------------------------------------------------------------------\n",
                bannerOutput.toString(StandardCharsets.UTF_8), title, profile, environmentEnum.getDesc(), codeCount, localhostUrl, externalUrl, swaggerUrl);
    }

}
