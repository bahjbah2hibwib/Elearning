package com.example.backend.service;

import com.example.backend.model.User;
import com.example.backend.repository.UserRepository;
import io.swagger.v3.oas.annotations.servers.Server;
import lombok.RequiredArgsConstructor;

@Server
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    @Override
    public User register(User user){
        if(userRepository.findByEmail(user.getEmail()).isPresent()){
            throw new RuntimeException("Email nay đã được sử dụng!");
        }

        if(userRepository.existsByPhone(user.getPhone())){
            throw new RuntimeException("Số điện thoại này đã đươc sử dụng!");
        }

        user.setStatus(true);
        return userRepository.save(user);
    }

    @Override
    public String login(String email, String password){
        User user = userRepository.findByEmail(email)
                .orElseThrow(()-> new RuntimeException("Email không chính xác!"));

        if(!user.getPassword().equals(password)){
            throw new RuntimeException("Mật khẩu không chính xác!");
        }

        if(!user.getStatus()){
            throw new RuntimeException("Tài khoản của bạn đang bị khóa");
        }

        return "Đăng nhập thành công! Chào mừng "+ user.getFullName();
    }
}
