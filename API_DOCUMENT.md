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

#### B. Business Logic & Step-by-Step Processing

1. **Validate dữ liệu:** Hệ thống tiếp nhận Request, thực hiện validate dữ liệu đầu vào theo quy tắc ở mục A.
2. **Kiểm tra trùng lặp:** Kiểm tra tính duy nhất của email bằng `userRepository.existsByEmail(email)`. Nếu đã tồn tại (`true`), ném lỗi `EmailAlreadyExistsException` (Trả về HTTP 400 Bad Request).
3. **Mã hóa mật khẩu:** Tiến hành mã hóa mật khẩu thô nhận được bằng thuật toán `BCryptPasswordEncoder`.
4. **Khởi tạo dữ liệu:** Tạo thực thể User mới với `role = 'ROLE_STUDENT'` và `status = true (ACTIVE)`.
5. **Lưu dữ liệu:** Thực hiện lưu thông tin xuống database qua `userRepository.save(user)`.

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 201 Created)**

```json
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
```

🔴 **Case 2: Email Already Exists (HTTP Status 400 Bad Request)**

```json
{
  "success": false,
  "errorCode": "EMAIL_ALREADY_EXISTS",
  "message": "Địa chỉ email người dùng đăng ký đã tồn tại trước đó!"
}
```

### 📝 API 02: ĐĂNG NHẬP HỆ THỐNG (LOGIN)

* **Endpoint:** `POST /api/v1/auth/login`
* **Content-Type:** `application/json`
* **Auth Required:** `None (Public)`

#### A. Request Specifications (Dữ liệu đầu vào)


| Field Name | Type | Required | Validation Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `email` | String | Yes | Format: Email | Email dùng để đăng nhập |
| `password` | String | Yes | Not Blank | Mật khẩu của tài khoản |

**Example Request Body:**
```json
{
  "email": "vna@gmail.com",
  "password": "SecurePassword123"
}
```

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm người dùng:** Tìm kiếm bản ghi dữ liệu người dùng tương ứng dựa vào email thông qua `userRepository.findByEmail(email)`. Nếu không tìm thấy, lập tức ném lỗi xác thực `BadCredentialsException` (Trả về HTTP 401 Unauthorized).
2. **Kiểm tra trạng thái:** Nếu tìm thấy người dùng, kiểm tra trạng thái tài khoản. Nếu `status == false` (Tài khoản bị khóa), lập tức ném lỗi `AccountLockedException` (Trả về HTTP 403 Forbidden).
3. **Đối sánh mật khẩu:** Sử dụng hàm `BCryptPasswordEncoder.matches()` để đối sánh mật khẩu thô gửi lên và mật khẩu băm trong DB. Nếu không trùng, ném lỗi `BadCredentialsException` (Trả về HTTP 401 Unauthorized).
4. **Sinh mã xác thực:** Khi tất cả các bước kiểm tra thành công, gọi thư viện mã hóa Token JWT để sinh chuỗi Access Token mới chứa thông tin `userId`, `email`, và `roles`.

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Login successfully",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtYWlsIjoidm5hQGdtYWlsLmNvbSIsInJvbGVzIjpbIlJPTEVfU1RVREVOVCJdfQ...",
  "tokenType": "Bearer",
  "expiresIn": 86400
}
```

🔴 **Case 2: Wrong Credentials (HTTP Status 401 Unauthorized)**

```json
{
  "success": false,
  "errorCode": "BAD_CREDENTIALS",
  "message": "Thông tin xác thực danh tính không chính xác (Sai email hoặc mật khẩu đăng nhập)."
}
```

🔴 **Case 3: Account Locked (HTTP Status 403 Forbidden)**

```json
{
  "success": false,
  "errorCode": "ACCOUNT_LOCKED",
  "message": "Tài khoản người dùng đang trong trạng thái bị khóa do vi phạm chính sách hệ thống."
}
```
