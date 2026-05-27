## 1. PHÂN HỆ AUTHENTICATION (MODULE A)

### 📝 API 01: ĐĂNG KÝ TÀI KHOẢN (REGISTER)
* [cite_start]**Endpoint:** `POST /api/v1/auth/register` [cite: 3, 39]
* **Content-Type:** `application/json`
* [cite_start]**Auth Required:** `None (Public)` [cite: 39]

#### A. Request Specifications (Dữ liệu đầu vào)
| Field Name | Type | Required | Validation Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `fullName` | String | Yes | Not Blank, Max 50 chars | [cite_start]Họ và tên người dùng [cite: 40] |
| `email` | String | Yes | Format: Email, Unique | [cite_start]Thư điện tử (Dùng đăng nhập) [cite: 40, 42] |
| `password` | String | Yes | Min 8 chars, 1 uppercase, 1 lowercase, 1 number | [cite_start]Mật khẩu tài khoản [cite: 40] |
| `phone` | String | No | Format: Phone number, Unique | Số điện thoại liên hệ |

**Example Request Body:**
```json
{
  "fullName": "Nguyen Van A",
  "email": "vna@gmail.com",
  "password": "SecurePassword123",
  "phone": "0987654321"
}
B. Business Logic & Step-by-Step ProcessingHệ thống tiếp nhận Request, thực hiện validate dữ liệu đầu vào theo quy tắc ở mục A.  Kiểm tra tính duy nhất của email bằng userRepository.existsByEmail(email). Nếu đã tồn tại (true), ném lỗi EmailAlreadyExistsException (Trả về HTTP 400 Bad Request).  Tiến hành mã hóa mật khẩu thô nhận được bằng thuật toán BCryptPasswordEncoder.  Tạo thực thể User mới với role = 'ROLE_STUDENT' và status = true (ACTIVE).  Thực hiện lưu thông tin xuống database qua userRepository.save(user).  C. Response Specifications (Dữ liệu đầu ra)🟢 Case 1: Success (HTTP Status 201 Created)JSON{
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
🔴 Case 2: Email Already Exists (HTTP Status 400 Bad Request)JSON{
  "success": false,
  "errorCode": "EMAIL_ALREADY_EXISTS",
  "message": "Địa chỉ email người dùng đăng ký đã tồn tại trước đó!" [cite: 163]
}
📝 API 02: ĐĂNG NHẬP HỆ THỐNG (LOGIN)Endpoint: POST /api/v1/auth/login   Content-Type: application/jsonAuth Required: None (Public)   A. Request Specifications (Dữ liệu đầu vào)Field NameTypeRequiredValidation RulesDescriptionemailStringYesFormat: EmailEmail dùng để đăng nhậppasswordStringYesNot BlankMật khẩu của tài khoảnExample Request Body:JSON{
  "email": "vna@gmail.com",
  "password": "SecurePassword123"
}
B. Business Logic & Step-by-Step ProcessingTìm kiếm bản ghi dữ liệu người dùng tương ứng dựa vào email thông qua userRepository.findByEmail(email).  Nếu không tìm thấy, lập tức ném lỗi xác thực BadCredentialsException (HTTP 401 Unauthorized).  Nếu tìm thấy người dùng, kiểm tra trạng thái tài khoản. Nếu status == false (Tài khoản bị khóa), lập tức ném lỗi AccountLockedException (HTTP 403 Forbidden).  Sử dụng hàm BCryptPasswordEncoder.matches() để đối sánh mật khẩu thô gửi lên và mật khẩu băm trong DB. Nếu không trùng, ném lỗi BadCredentialsException (HTTP 401 Unauthorized).  Khi tất cả các bước kiểm tra thành công, gọi thư viện mã hóa Token JWT để sinh chuỗi Access Token mới chứa thông tin userId, email, và roles.  C. Response Specifications (Dữ liệu đầu ra)🟢 Case 1: Success (HTTP Status 200 OK)JSON{
  "success": true,
  "message": "Login successfully",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtYWlsIjoidm5hQGdtYWlsLmNvbSIsInJvbGVzIjpbIlJPTEVfU1RVREVOVCJdfQ...",
  "tokenType": "Bearer",
  "expiresIn": 86400
}
🔴 Case 2: Wrong Credentials (HTTP Status 401 Unauthorized)JSON{
  "success": false,
  "errorCode": "BAD_CREDENTIALS",
  "message": "Thông tin xác thực danh tính không chính xác (Sai email hoặc mật khẩu đăng nhập)." [cite: 163]
}
🔴 Case 3: Account Locked (HTTP Status 403 Forbidden)JSON{
  "success": false,
  "errorCode": "ACCOUNT_LOCKED",
  "message": "Tài khoản người dùng đang trong trạng thái bị khóa do vi phạm chính sách hệ thống." [cite: 163]
}