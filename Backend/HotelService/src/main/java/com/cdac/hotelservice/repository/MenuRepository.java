package com.cdac.hotelservice.repository;

import com.cdac.hotelservice.entity.Menu;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MenuRepository extends JpaRepository<Menu, Long> {
    List<Menu> findByHotelId(Long hotelId);
}
