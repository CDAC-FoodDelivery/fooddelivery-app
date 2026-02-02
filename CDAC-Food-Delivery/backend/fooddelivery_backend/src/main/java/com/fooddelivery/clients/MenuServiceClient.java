package com.fooddelivery.clients;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "menu-service")
public interface MenuServiceClient {

    @GetMapping("/api/menu/{id}")
    Object getMenuById(@PathVariable("id") Long id);

    @GetMapping("/api/menu")
    Object getAllMenus();

    @PostMapping("/api/menu")
    Object createMenu(@RequestBody Object menuRequest);
}
