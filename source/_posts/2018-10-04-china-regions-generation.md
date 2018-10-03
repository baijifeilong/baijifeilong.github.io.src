---
title: 使用SpringJdbc生成省市县三级JSON
categories:
  - Programming
tags:
  - Programming
date: 2018-10-04 01:31:51
---

```java
package bj;

import com.mysql.cj.jdbc.MysqlDataSource;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.List;
import java.util.stream.Collectors;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class, DataSourceTransactionManagerAutoConfiguration.class, HibernateJpaAutoConfiguration.class})
public class App implements ApplicationListener<ApplicationReadyEvent> {
    public static void main(String[] args) {
        new SpringApplicationBuilder(App.class).web(false).run(args);
    }


    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        JdbcTemplate jdbcTemplate = new JdbcTemplate(new MysqlDataSource() {{
            setUser("robot");
            setPassword("robot");
            setDatabaseName("robot");
        }});

        List<?> provinces = jdbcTemplate.queryForList("SELECT * FROM district where parent_id = 0").stream().map(item -> new JSONObject() {{
            put("code", item.get("code"));
            put("name", item.get("name"));
            put("children", jdbcTemplate.queryForList("SELECT * FROM district WHERE parent_id = ?", item.get("id"))
                    .stream().map(item -> new JSONObject() {{
                        put("code", item.get("code"));
                        put("name", item.get("name"));
                        put("children", jdbcTemplate.queryForList("SELECT * FROM district WHERE parent_id = ?", item.get("id"))
                                .stream().map(item -> new JSONObject() {{
                                    put("code", item.get("code"));
                                    put("name", item.get("name"));
                                }}).collect(Collectors.toList()));
                    }}).collect(Collectors.toList()));
        }}).collect(Collectors.toList());

        JSONArray jsonArray = new JSONArray(provinces);
        System.out.println(jsonArray.toString());
    }
}

```
