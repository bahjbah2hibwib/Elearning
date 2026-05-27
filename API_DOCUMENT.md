# 🔐 DANH SÁCH TÀI LIỆU ĐẶC TẢ API HỆ THỐNG E-LEARNING

## 1. PHÂN HỆ AUTHENTICATION (MODULE A)

### 📝 API 01: ĐĂNG KÝ TÀI KHOẢN (REGISTER)
* **Endpoint:** `POST /api/v1/auth/register`
* **Content-Type:** `application/json`
* **Auth Required:** `None (Public)`

#### A. Request Specifications (Dữ liệu đầu vào)
| Field Name | Type | Required | Validation Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `fullName` | String | Yes | Not Blank, Max 100 chars | Họ và tên người dùng |
| `email` | String | Yes | Format: Email, Unique | Thư điện tử (Dùng đăng nhập) |
| `password` | String | Yes | Min 8 chars, strong password | Mật khẩu tài khoản |
| `phone` | String | No | Format: Phone number, Unique | Số điện thoại liên hệ |

**Example Request Body:**
```json
{
  "fullName": "Nguyen Van A",
  "email": "vna@gmail.com",
  "password": "SecurePassword123",
  "phone": "0987654321"
}
```
B. Business Logic & Step-by-Step Processing
Hệ thống tiếp nhận Request, thực hiện validate dữ liệu đầu vào theo quy tắc ở mục A.

Kiểm tra tính duy nhất của email bằng userRepository.existsByEmail(email). Nếu đã tồn tại (true), ném lỗi EmailAlreadyExistsException (Trả về HTTP 400 Bad Request).

Tiến hành mã hóa mật khẩu thô nhận được bằng thuật toán BCryptPasswordEncoder.

Tạo thực thể User mới với role = 'ROLE_STUDENT' và status = true (ACTIVE).

Thực hiện lưu thông tin xuống database qua userRepository.save(user).

C. Response Specifications (Dữ liệu đầu ra)
🟢 Case 1: Success (HTTP Status 201 Created)
JSON
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "userId": 1,
    "fullName": "Nguyen Van A",
    "email": "vna@gmail.com",
    "phone": "0987654321",
    "role": "ROLE_STUDENT",
    "status": true,
    "createdAt": "2026-05-27T23:15:00"
  }
}
🔴 Case 2: Email Already Exists (HTTP Status 400 Bad Request)
JSON
{
  "success": false,
  "errorCode": "EMAIL_ALREADY_EXISTS",
  "message": "Địa chỉ email người dùng đăng ký đã tồn tại trước đó!"
}