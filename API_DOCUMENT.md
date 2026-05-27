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

### 📝 API 03: XEM THÔNG TIN HỒ SƠ CÁ NHÂN HIỆN TẠI

* **Endpoint:** `GET /api/v1/users/me`
* **Content-Type:** `None` (API dạng GET không truyền Body gửi lên)
* **Auth Required:** `Đăng nhập hệ thống` (Yêu cầu Token hợp lệ)

#### A. Request Specifications (Dữ liệu đầu vào)

API này không yêu cầu Client phải truyền tham số gì lên URL hay Body. Hệ thống sẽ tự động nhận biết người dùng là ai thông qua chuỗi Token đính kèm ở Header của Request.

#### B. Business Logic & Step-by-Step Processing

1. **Trích xuất thông tin:** Hệ thống tự động bóc tách thông tin định danh mã người dùng `userId` từ `SecurityContextHolder` (Do bộ lọc mã JWT Filter trích xuất xử lý trước đó).
2. **Truy vấn dữ liệu:** Truy vấn trực tiếp dữ liệu cơ sở từ `userRepository.findById(userId)`.
3. **Kiểm tra tồn tại:** Kiểm tra xem người dùng có tồn tại không. Nếu không tìm thấy đối tượng thực thể tương ứng, lập tức chặn lại và ném ngoại lệ dữ liệu `ResourceNotFoundException` (Trả về HTTP Status 404 Not Found).
4. **Ánh xạ dữ liệu (Mapping):** Nếu tìm thấy, thực hiện chuyển đổi ánh xạ từ đối tượng thực thể `User` sang cấu trúc lớp dữ liệu an toàn `UserDTO` nhằm che giấu triệt để mật khẩu và các thông tin hệ thống nhạy cảm trước khi gửi về giao diện.

🛠️ **Yêu cầu tầng Repository:**
Sử dụng hàm cấu hình cơ bản sẵn có của Spring Data JPA:
```java
Optional<User> findById(Integer id);
```
*(Lưu ý: Đồng bộ kiểu dữ liệu `Integer` cho khóa chính theo thiết kế hệ thống).*

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

*Trả về gói dữ liệu JSON chứa thông tin hồ sơ sạch (UserDTO) đã được loại bỏ password:*

```json
{
  "success": true,
  "message": "Lấy thông tin cá nhân thành công",
  "data": {
    "userId": 1,
    "fullName": "Nguyen Van A",
    "email": "vna@gmail.com",
    "phone": "0987654321",
    "avatar": "https://link-anh.com/avatar.png",
    "role": "ROLE_STUDENT",
    "status": true,
    "createdAt": "2026-05-27T23:15:00"
  }
}
```

🔴 **Case 2: Error - User Not Found (HTTP Status 404 Not Found)**

```json
{
  "success": false,
  "errorCode": "RESOURCE_NOT_FOUND",
  "message": "Không tìm thấy thông tin người dùng tương ứng trong hệ thống!"
}
```

### 📝 API 04: CẬP NHẬT THÔNG TIN CÁ NHÂN

* **Endpoint:** `PUT /api/v1/users/me`
* **Content-Type:** `application/json`
* **Auth Required:** `Đăng nhập hệ thống` (Yêu cầu Token hợp lệ)

#### A. Request Specifications (Dữ liệu đầu vào)

Hệ thống lấy `userId` ngầm từ Token, người dùng chỉ cần gửi lên các trường thông tin muốn thay đổi qua Body:


| Field Name | Type | Required | Validation Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `fullName` | String | Yes | Not Blank, Max 50 chars | Họ và tên mới muốn cập nhật |
| `phone` | String | No | Format: Phone number, Unique | Số điện thoại mới muốn cập nhật |
| `avatar` | String | No | Format: URL | Đường dẫn ảnh đại diện mới |
| `dateOfBirth` | String | No | Format: YYYY-MM-DD | Ngày tháng năm sinh |

**Example Request Body:**
```json
{
  "fullName": "Nguyen Van A Sau Khi Doi Ten",
  "phone": "0912345678",
  "avatar": "https://link-anh.com/avatar_moi.png",
  "dateOfBirth": "2000-02-02"
}
```

#### B. Business Logic & Step-by-Step Processing

1. **Trích xuất thông tin:** Hệ thống tự động bóc tách thông tin định danh `userId` từ Token thông qua `SecurityContextHolder`.
2. **Tìm kiếm người dùng:** Gọi `userRepository.findById(userId)` để tìm thực thể người dùng hiện tại. Nếu không tìm thấy, ném lỗi `ResourceNotFoundException` (Trả về HTTP Status 404 Not Found).
3. **Kiểm tra trùng lặp:** Kiểm tra trùng lặp số điện thoại (Nếu người dùng có thay đổi số điện thoại cũ). Gọi `userRepository.existsByPhone(request.getPhone())`. Nếu số điện thoại mới đã bị tài khoản khác chiếm dụng, ném lỗi `BadRequestException` hoặc `RuntimeException` ("Số điện thoại đã tồn tại") (Trả về HTTP Status 400 Bad Request).
4. **Cập nhật dữ liệu:** Tiến hành đè dữ liệu mới từ Request (`fullName`, `phone`, `avatar`, `dateOfBirth`) vào thực thể User vừa tìm được ở bước 2.
5. **Lưu trữ dữ liệu:** Lưu trữ dữ liệu mới xuống database bằng cách gọi hàm `userRepository.save(user)`.

🛠️ **Yêu cầu tầng Repository:**
Bổ sung hàm kiểm tra trùng số điện thoại nếu chưa có:
```java
boolean existsByPhone(String phone);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

*Trả về thông tin hồ sơ mới nhất (UserDTO) sau khi cập nhật thành công:*

```json
{
  "success": true,
  "message": "Cập nhật thông tin cá nhân thành công",
  "data": {
    "userId": 1,
    "fullName": "Nguyen Van A Sau Khi Doi Ten",
    "email": "vna@gmail.com",
    "phone": "0912345678",
    "avatar": "https://link-anh.com/avatar_moi.png",
    "role": "ROLE_STUDENT",
    "status": true,
    "createdAt": "2026-05-27T23:15:00",
    "updatedAt": "2026-05-28T01:14:39"
  }
}
```

🔴 **Case 2: Error - Phone Already Exists (HTTP Status 400 Bad Request)**

```json
{
  "success": false,
  "errorCode": "PHONE_ALREADY_EXISTS",
  "message": "Số điện thoại này đã được sử dụng bởi một tài khoản khác!"
}
```

🔴 **Case 3: Error - User Not Found (HTTP Status 404 Not Found)**

```json
{
  "success": false,
  "errorCode": "RESOURCE_NOT_FOUND",
  "message": "Không tìm thấy thông tin người dùng tương ứng để cập nhật!"
}
```
