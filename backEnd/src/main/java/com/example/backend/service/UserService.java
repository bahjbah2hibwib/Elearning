package com.example.backend.service;

import com.example.backend.model.User;

public interface UserService {
    // Nhận vào đầy đủ thông tin User, trả về User sau khi lưu thành công
    User register(User user);

    // Nhận vào email, password, trả về một chuỗi thông báo kết quả
    String login(String email, String password);
}
