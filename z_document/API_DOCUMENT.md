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
## 2. PHÂN HỆ QUẢN LÝ NGƯỜI DÙNG (MODULE B)

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

### 📝 API 05: ĐỔI MẬT KHẨU

* **Endpoint:** `PUT /api/v1/users/change-password`
* **Content-Type:** `application/json`
* **Auth Required:** `Đăng nhập hệ thống` (Yêu cầu Token hợp lệ)

#### A. Request Specifications (Dữ liệu đầu vào)

| Field Name | Type | Required | Validation Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `oldPassword` | String | Yes | Not Blank | Mật khẩu hiện tại của người dùng |
| `newPassword` | String | Yes | Min 8 chars, 1 uppercase, 1 lowercase, 1 number | Mật khẩu mới muốn thay đổi |

**Example Request:**
```json
{
  "oldPassword": "OldPassword123",
  "newPassword": "NewSecurePassword123"
}
```

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Hệ thống bóc tách `userId` ngầm từ Token trong phiên làm việc hiện tại.
2. **Step 2:** Gọi `userRepository.findById(userId)` để truy vấn thực thể. Nếu rỗng, ném lỗi `ResourceNotFoundException` (HTTP Status 404).
3. **Step 3:** Dùng `passwordEncoder.matches(request.getOldPassword(), user.getPassword())` để kiểm tra mật khẩu cũ. Nếu kết quả là `false`, lập tức ném lỗi `BadCredentialsException` (HTTP Status 401).
4. **Step 4:** Thực thi logic chính: Tiến hành băm mật khẩu mới bằng `passwordEncoder.encode(request.getNewPassword())` và cập nhật vào thuộc tính mật khẩu của đối tượng.
5. **Step 5:** Gọi hàm `userRepository.save(user)` để đồng bộ xuống cơ sở dữ liệu.

🛠️ **Tầng Repository yêu cầu:**
Sử dụng hàm cơ bản:
```java
Optional<User> findById(Integer id);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Đổi mật khẩu thành công!"
}
```

🔴 **Case 2: Error - Wrong Old Password (HTTP Status 401 Unauthorized)**

```json
{
  "success": false,
  "errorCode": "BAD_CREDENTIALS",
  "message": "Mật khẩu hiện tại không chính xác!"
}
```

### 📝 API 06: DANH SÁCH NGƯỜI DÙNG PHÂN TRANG VÀ LỌC (ADMIN)

* **Endpoint:** `GET /api/v1/users`
* **Content-Type:** `None`
* **Auth Required:** `Tài khoản có quyền ROLE_ADMIN`

#### A. Request Specifications (Query Parameters trên URL)

| Parameter | Type | Required | Default Value | Description |
| :--- | :--- | :--- | :--- | :--- |
| `page` | Integer | No | `0` | Số thứ tự trang muốn lấy (bắt đầu từ 0) |
| `size` | Integer | No | `10` | Số lượng người dùng hiển thị trên một trang |
| `keyword` | String | No | Không có | Từ khóa dùng để tìm kiếm theo Họ tên hoặc Email |

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Kiểm tra ràng buộc tham số đầu vào, khởi tạo đối tượng `Pageable` từ dữ liệu `page` và `size` nhận được.
2. **Step 2:** Kiểm tra tính trống của tham số tìm kiếm `keyword`:
   - Trường hợp có truyền `keyword`: Gọi hàm `userRepository.findByFullNameContainingIgnoreCaseOrEmailContainingIgnoreCase(keyword, keyword, pageable)`.
   - Trường hợp `keyword` trống/không truyền: Gọi hàm `userRepository.findAll(pageable)`.
3. **Step 3:** Duyệt qua danh sách kết quả `Page<User>`, thực hiện ánh xạ (Mapping) chuyển đổi sang cấu trúc lớp dữ liệu an toàn `Page<UserDTO>` để giấu trường mật khẩu nhạy cảm.

🛠️ **Tầng Repository yêu cầu:**
```java
Page<User> findByFullNameContainingIgnoreCaseOrEmailContainingIgnoreCase(String fullName, String email, Pageable pageable);
Page<User> findAll(Pageable pageable);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy danh sách người dùng thành công",
  "data": {
    "content": [
      {
        "userId": 2,
        "fullName": "Nguyen Van B",
        "email": "vnb@gmail.com",
        "phone": "0911222333",
        "role": "ROLE_STUDENT",
        "status": true
      }
    ],
    "pageNumber": 0,
    "pageSize": 10,
    "totalElements": 1,
    "totalPages": 1,
    "last": true
  }
}
```

### 📝 API 07: XEM CHI TIẾT NGƯỜI DÙNG

* **Endpoint:** `GET /api/v1/users/{id}`
* **Content-Type:** `None`
* **Auth Required:** `Tài khoản có quyền ROLE_ADMIN`

#### A. Request Specifications (Path Variables)

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | Integer | Yes | ID của người dùng hệ thống cần truy vấn chi tiết |

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Tiếp nhận mã định danh người dùng mục tiêu thông qua biến đường dẫn `id`.
2. **Step 2:** Thực hiện tìm kiếm trong DB bằng `userRepository.findById(id)`.
3. **Step 3:** Nếu kết quả trả về trống, ném ngay ngoại lệ hệ thống `ResourceNotFoundException` (Trả về HTTP Status 404 Not Found).
4. **Step 4:** Nếu tìm thấy, ánh xạ thực thể thành `UserDTO` để trả về cho Client nhằm che giấu trường bảo mật nhạy cảm.

🛠️ **Tầng Repository yêu cầu:**
Sử dụng hàm cơ bản:
```java
Optional<User> findById(Integer id);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy thông tin người dùng thành công",
  "data": {
    "userId": 5,
    "fullName": "Tran Van C",
    "email": "tvc@gmail.com",
    "phone": "0922333444",
    "avatar": "https://link.com/avatar.png",
    "role": "ROLE_INSTRUCTOR",
    "status": true,
    "createdAt": "2026-05-01T10:00:00"
  }
}
```

🔴 **Case 2: Error - Not Found (HTTP Status 404 Not Found)**

```json
{
  "success": false,
  "errorCode": "RESOURCE_NOT_FOUND",
  "message": "Không tìm thấy người dùng có ID tương ứng trong hệ thống!"
}
```

### 📝 API 08: KHÓA TÀI KHOẢN HỆ THỐNG

* **Endpoint:** `PATCH /api/v1/users/{id}/lock`
* **Content-Type:** `None`
* **Auth Required:** `Tài khoản có quyền ROLE_ADMIN`

#### A. Request Specifications (Path Variables)

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | Integer | Yes | ID của người dùng đích cần thực hiện hành vi khóa |

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Hệ thống tiếp nhận mã `id` từ biến đường dẫn.
2. **Step 2:** Tìm thực thể bằng `userRepository.findById(id)`. Nếu rỗng, ném ngay lỗi `ResourceNotFoundException`.
3. **Step 3:** Thực hiện kiểm tra an toàn hệ thống (System Safety Check):
   - Đối sánh nếu `id == currentAdminId` (Admin tự khóa chính mình) hoặc tài khoản đích có quyền `ROLE_ADMIN` (khóa tài khoản quản trị viên đồng cấp khác).
   - Nếu vi phạm điều kiện trên, lập tức chặn hành vi và ném lỗi `BadRequestException` (HTTP Status 400 Bad Request).
4. **Step 4:** Nếu đáp ứng điều kiện, cập nhật thuộc tính logic trạng thái vận hành hệ thống sang thế bị khóa: `user.setStatus(false)`.
5. **Step 5:** Gọi hàm `userRepository.save(user)` để lưu dữ liệu cập nhật xuống DB.

🛠️ **Tầng Repository yêu cầu:**
Sử dụng hàm cơ bản:
```java
Optional<User> findById(Integer id);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Account locked successfully"
}
```

🔴 **Case 2: Error - Self Lock / Peer Admin Lock (HTTP Status 400 Bad Request)**

```json
{
  "success": false,
  "errorCode": "BAD_REQUEST",
  "message": "Hệ thống tuyệt đối chặn đứng hành vi Admin tự khóa chính mình hoặc khóa tài khoản của các quản trị viên đồng cấp!"
}
```

### 📝 API 09: MỞ KHÓA TÀI KHOẢN HỆ THỐNG

* **Endpoint:** `PATCH /api/v1/users/{id}/unlock`
* **Content-Type:** `None`
* **Auth Required:** `Tài khoản có quyền ROLE_ADMIN`

#### A. Request Specifications (Path Variables)

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | Integer | Yes | ID của người dùng đích cần thực hiện mở khóa |

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Tìm thực thể bằng mã truyền vào qua `userRepository.findById(id)`. Nếu rỗng, ném lỗi `ResourceNotFoundException`.
2. **Step 2:** Thay đổi giá trị trường trạng thái logic vận hành quay về trạng thái hoạt động bình thường: `user.setStatus(true)`.
3. **Step 3:** Đồng bộ cấu hình mới xuống cơ sở dữ liệu bằng lệnh `userRepository.save(user)`.

🛠️ **Tầng Repository yêu cầu:**
Sử dụng hàm cơ bản:
```java
Optional<User> findById(Integer id);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Account unlocked successfully"
}
```

## 3. PHÂN HỆ KHÓA HỌC TRỰC TUYẾN (MODULE C)

### 📝 API 10: DANH SÁCH KHÓA HỌC XUẤT BẢN CÔNG KHAI

* **Endpoint:** `GET /api/v1/courses`
* **Content-Type:** `None`
* **Auth Required:** `None (Public)`

#### A. Request Specifications (Query Parameters trên URL)

| Parameter | Type | Required | Default Value | Description |
| :--- | :--- | :--- | :--- | :--- |
| `page` | Integer | No | `0` | Số thứ tự trang muốn lấy |
| `size` | Integer | No | `10` | Số lượng phần tử hiển thị trên một trang |

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Khởi tạo đối tượng phân trang `Pageable`.
2. **Step 2:** Hệ thống chỉ cho phép tra cứu các khóa học đã chính thức xuất bản rộng rãi ra công chúng. Thực hiện gọi hàm truy vấn từ database: `courseRepository.findByStatus("APPROVED", pageable)`.
3. **Step 3:** Trả về tập kết quả chứa danh sách các khóa học phục vụ cho hiển thị tại giao diện trang chủ.

🛠️ **Tầng Repository yêu cầu:**
```java
Page<Course> findByStatus(String status, Pageable pageable);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy danh sách khóa học thành công",
  "data": {
    "content": [
      {
        "courseId": 1,
        "title": "Lập trình Java Spring Boot Web chuyên nghiệp",
        "description": "Khóa học nền tảng cung cấp kiến thức thực chiến...",
        "thumbnailUrl": "https://link.com/java.png",
        "status": "APPROVED"
      }
    ],
    "pageNumber": 0,
    "pageSize": 10,
    "totalElements": 1,
    "totalPages": 1,
    "last": true
  }
}
```

### 📝 API 11: TRA CỨU THÔNG TIN CHI TIẾT CỦA MỘT KHÓA HỌC

* **Endpoint:** `GET /api/v1/courses/{courseId}`
* **Content-Type:** `None`
* **Auth Required:** `Public` (Nhưng áp dụng các điều kiện kiểm tra bảo mật nghiêm ngặt bên dưới)

#### A. Request Specifications (Path Variables)

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `courseId` | Integer | Yes | Mã định danh duy nhất của khóa học cần tra cứu chi tiết |

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Tiếp nhận mã định danh khóa học qua biến đường dẫn `courseId`, thực hiện tìm kiếm qua `courseRepository.findById(courseId)`. Nếu trống, ném ngay ngoại lệ hệ thống `ResourceNotFoundException` (HTTP Status 404).
2. **Step 2:** Thực hiện kiểm tra tính bảo mật trạng thái khóa học (Visibility Check Logic):
   - **Trường hợp 1:** Nếu trạng thái của khóa học đang lưu ở DB là dạng xuất bản công khai `APPROVED`, hệ thống cho phép đi tiếp trực tiếp mà không cần check phiên làm việc.
   - **Trường hợp 2:** Nếu trạng thái khóa học đang ở thế chờ duyệt `PENDING` hoặc ẩn nội bộ `HIDDEN`, hệ thống yêu cầu kiểm tra thông tin phiên làm việc của Client. Người dùng gửi yêu cầu bắt buộc phải sở hữu vai trò quản trị hệ thống `ROLE_ADMIN` hoặc phải chính là chủ sở hữu (Giảng viên đã tạo dựng ra khóa học này: đối sánh trường dữ liệu `instructorId == currentUserId`). Nếu không đáp ứng, ném ra ngoại lệ từ chối quyền `AccessDeniedException` (HTTP Status 403 Forbidden).
3. **Step 3:** Tiến hành đóng gói dữ liệu và trả về cấu trúc đối tượng chi tiết `CourseDetailDTO` bao gồm đầy đủ dữ liệu tổng quan khóa học đi kèm danh sách bài học liên kết trực thuộc.

🛠️ **Tầng Repository yêu cầu:**
Sử dụng hàm cơ bản:
```java
Optional<Course> findById(Integer courseId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy thông tin chi tiết khóa học thành công",
  "data": {
    "courseId": 1,
    "title": "Lập trình Java Spring Boot Web chuyên nghiệp",
    "description": "Khóa học nền tảng cung cấp kiến thức thực chiến...",
    "thumbnailUrl": "https://link.com/java.png",
    "status": "APPROVED",
    "instructorName": "Giảng viên Nguyễn Văn A",
    "lessons": [
      {
        "lessonId": 101,
        "title": "Bài 1: Cài đặt môi trường và cấu hình Docker Docker-Compose"
      }
    ]
  }
}
```

🔴 **Case 2: Error - Access Denied (HTTP Status 403 Forbidden)**

```json
{
  "success": false,
  "errorCode": "ACCESS_DENIED",
  "message": "Bạn không có quyền hạn vai trò để truy cập thông tin khóa học nội bộ này!"
}
```

📝 API 12: GIẢNG VIÊN TẠO KHÓA HỌC MỚI TRONG HỆ THỐNGEndpoint: POST /api/v1/coursesContent-Type: application/jsonAuth Required: Tài khoản có quyền giảng viên hệ thống ROLE_INSTRUCTORA. Request Specifications (Dữ liệu đầu vào từ Request Body)Field NameTypeRequiredValidation RulesDescriptiontitleStringYesNot Blank, độ dài từ 10 đến 150 ký tựTiêu đề khóa học mớidescriptionStringYesNot BlankMô tả chi tiết nội dung khóa họcthumbnailUrlStringYesFormat: URLĐường dẫn ảnh đại diện hiển thị của khóa họcExample Request:JSON{
  "title": "Cấu trúc dữ liệu và Giải thuật cơ bản",
  "description": "Khóa học cung cấp kiến thức chuyên sâu về danh sách liên kết, cây, đồ thị...",
  "thumbnailUrl": "https://link.com/dsa.png"
}
```

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Trích xuất dữ liệu định danh người dùng từ Token xác thực để lấy mã `currentUserId` của giảng viên đang thao tác. Gọi DB qua `UserRepository` kiểm tra tính hợp lệ và tồn tại của đối tượng Giảng viên.
2. **Step 2:** Tiếp nhận gói dữ liệu payload thông tin khóa học mới từ Request Body.
3. **Step 3:** Khởi tạo một thực thể `Course` mới hoàn toàn, nạp các dữ liệu cấu hình client cung cấp, đồng thời thiết lập ánh xạ quan hệ đối tượng sở hữu tới thực thể Giảng viên vừa tìm được ở Step 1.
4. **Step 4:** Thiết lập trạng thái phê duyệt mặc định ban đầu cho khóa học mới là `PENDING` (Trạng thái chờ kiểm duyệt nội dung bởi Quản trị viên hệ thống trước khi chính thức xuất bản rộng rãi).
5. **Step 5:** Gọi hàm xử lý của lớp `courseRepository.save(course)` để thực hiện ghi thông tin xuống database PostgreSQL.

🛠️ **Tầng Repository yêu cầu:**
Sử dụng hàm cơ bản sẵn có của JPA:
```java
Course save(Course course);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 201 Created)**

```json
{
  "success": true,
  "message": "Khởi tạo khóa học thành công! Vui lòng chờ Admin phê duyệt.",
  "data": {
    "courseId": 2,
    "title": "Cấu trúc dữ liệu và Giải thuật cơ bản",
    "description": "Khóa học cung cấp kiến thức chuyên sâu về danh sách liên kết, cây, đồ thị...",
    "thumbnailUrl": "https://link.com/dsa.png",
    "status": "PENDING",
    "createdAt": "2026-05-28T01:20:00"
  }
}
```

### 📝 API 13: CẬP NHẬT THÔNG TIN KHÓA HỌC

* **Endpoint:** `PUT /api/v1/courses/{courseId}`
* **Content-Type:** `application/json`
* **Auth Required:** `Tài khoản có quyền ROLE_INSTRUCTOR (Phải là chủ sở hữu khóa học) hoặc ROLE_ADMIN`

#### A. Request Specifications (Dữ liệu đầu vào)

- **Path Variables:** `courseId` (ID khóa học cần sửa)
- **Request Body:** Các trường thông tin cập nhật mới:
```json
{
  "title": "Cấu trúc dữ liệu và Giải thuật nâng cao 2026",
  "description": "Nội dung cập nhật chuyên sâu các thuật toán đồ thị...",
  "thumbnailUrl": "https://link.com/dsa_new.png"
}
```

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Gọi `courseRepository.findById(courseId)` để tìm thực thể. Nếu trống, ném lỗi `ResourceNotFoundException`.
2. **Step 2:** Kiểm tra quyền: Đối sánh xem `currentUserId` từ token có trùng khớp với `instructorId` liên kết với khóa học không. Nếu không trùng và người dùng không phải Admin, chặn quyền bằng cách ném lỗi `AccessDeniedException`.
3. **Step 3:** Tiến hành đè dữ liệu mới từ Request vào đối tượng thực thể tìm được. Đổi trạng thái khóa học quay về thế `PENDING` để Admin kiểm duyệt lại từ đầu nhằm tránh tình trạng đổi nội dung rác sau khi đã được duyệt.
4. **Step 4:** Gọi hàm `courseRepository.save(course)` để cập nhật DB.

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Cập nhật thông tin khóa học thành công!",
  "data": {
    "courseId": 2,
    "title": "Cấu trúc dữ liệu và Giải thuật nâng cao 2026",
    "status": "PENDING"
  }
}
```

### 📝 API 14: ẨN KHÓA HỌC NỘI BỘ

* **Endpoint:** `PATCH /api/v1/courses/{courseId}/hide`
* **Content-Type:** `None`
* **Auth Required:** `Quyền Giảng viên sở hữu khóa học (ROLE_INSTRUCTOR) hoặc Quản trị viên (ROLE_ADMIN)`

#### A. Request Specifications (Path Variables)

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `courseId` | Integer | Yes | ID khóa học muốn ẩn khỏi màn hình trang chủ |

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Tìm kiếm thực thể qua `courseRepository.findById(courseId)`. Nếu trống, quăng ngoại lệ `ResourceNotFoundException`.
2. **Step 2:** Kiểm tra tính chủ sở hữu tương tự mục 3.2 (Chỉ có Admin hoặc Giảng viên tạo ra nó mới có quyền ẩn).
3. **Step 3:** Thực thi logic chính: Cập nhật giá trị trường thuộc tính trạng thái sang thế ẩn nội bộ: `course.setStatus("HIDDEN")`.
4. **Step 4:** Gọi hàm `courseRepository.save(course)` để đồng bộ PostgreSQL.

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Khóa học đã được ẩn khỏi hệ thống công khai thành công."
}
```

### 📝 API 15: PHÊ DUYỆT XUẤT BẢN KHÓA HỌC

* **Endpoint:** `PATCH /api/v1/courses/{courseId}/approve`
* **Content-Type:** `None`
* **Auth Required:** `Tài khoản có quyền quản trị cao cấp ROLE_ADMIN`

#### A. Request Specifications (Path Variables)

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `courseId` | Integer | Yes | Mã khóa học mục tiêu mà Admin cần thực hiện phê duyệt |

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Tìm kiếm khóa học cha qua `courseRepository.findById(courseId)`. Nếu không có bản ghi, ném lỗi `ResourceNotFoundException`.
2. **Step 2:** Thực thi logic chính: Thay đổi giá trị trường trạng thái phê duyệt nội dung sang thế công khai: `course.setStatus("APPROVED")`.
3. **Step 3:** Lưu cấu hình mới xuống DB PostgreSQL: `courseRepository.save(course)`.

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Khóa học đã được phê duyệt và xuất bản công khai ra hệ thống thành công!"
}
```

### 📝 API 16: DANH SÁCH KHÓA HỌC CỦA RIÊNG GIẢNG VIÊN

* **Endpoint:** `GET /api/v1/courses/my-courses`
* **Content-Type:** `None`
* **Auth Required:** `Tài khoản giảng viên hệ thống ROLE_INSTRUCTOR`

#### A. Request Specifications (Dữ liệu đầu vào)

API lấy danh sách toàn bộ khóa học do chính ông giảng viên đó tạo lập ra, không cần tham số gì gửi lên URL. Mã định danh sẽ lấy trực tiếp qua Token ngầm.

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Trích xuất dữ liệu định danh giảng viên hiện tại `currentInstructorId` từ Token xác thực.
2. **Step 2:** Thực hiện truy vấn trực tiếp dữ liệu cơ sở từ tầng Repository: `courseRepository.findByInstructor_UserId(currentInstructorId)`.
3. **Step 3:** Trả về toàn bộ danh sách các khóa học (bao gồm cả dạng PENDING, APPROVED, HIDDEN) để giảng viên tự theo dõi tiến độ của bản thân.

🛠️ **Tầng Repository yêu cầu:**
```java
List<Course> findByInstructor_UserId(Integer instructorId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy danh sách khóa học nội bộ của giảng viên thành công",
  "data": [
    {
      "courseId": 1,
      "title": "Lập trình Java Spring Boot Web chuyên nghiệp",
      "status": "APPROVED"
    },
    {
      "courseId": 2,
      "title": "Cấu trúc dữ liệu và Giải thuật cơ bản",
      "status": "PENDING"
    }
  ]
}
```

## 4. PHÂN HỆ BÀI HỌC VÀ TIẾN ĐỘ HỌC TẬP (MODULE D & F)

### 📝 API 17: TẠO BÀI HỌC MỚI TRONG KHÓA HỌC

* **Endpoint:** `POST /api/v1/courses/{courseId}/lessons`
* **Content-Type:** `application/json`
* **Auth Required:** `Quyền Giảng viên chủ quản (ROLE_INSTRUCTOR) hoặc Admin (ROLE_ADMIN)`

#### A. Request Specifications (Dữ liệu đầu vào)

- **Path Variables:** `courseId` (Xác định bài học này thuộc về khóa học cha nào)
- **Request Body Specifications:**

| Field Name | Type | Required | Validation Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `title` | String | Yes | Not Blank | Tiêu đề hiển thị của bài học |
| `orderIndex` | Integer | Yes | Min = 1 | Thứ tự sắp xếp của bài học trong khóa học |

**Example Request:**
```json
{
  "title": "Tổng quan kiến trúc MVC trong Spring Boot",
  "orderIndex": 1
}
```

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Tìm khóa học cha dựa trên tham số đường dẫn `courseId` qua `courseRepository.findById(courseId)`. Nếu không tìm thấy, báo lỗi dữ liệu `ResourceNotFoundException` (HTTP Status 404).
2. **Step 2:** Kiểm tra quyền bảo mật: Chỉ cho phép Admin hoặc chính Giảng viên tạo ra khóa học này thực hiện thêm bài học (đối sánh trường dữ liệu `instructorId == currentUserId`). Nếu không khớp, ném lỗi `AccessDeniedException`.
3. **Step 3:** Thực thi logic chính: Khởi tạo thực thể `Lesson` mới, gán trường thông tin `title`, `orderIndex` và liên kết trực tiếp mối quan hệ đối tượng khóa ngoại tới thực thể `Course` tìm được ở Step 1.
4. **Step 4:** Thực hiện lưu dữ liệu bài học mới xuống database PostgreSQL qua `lessonRepository.save(lesson)`.

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 201 Created)**

```json
{
  "success": true,
  "message": "Khởi tạo bài học mới thành công!",
  "data": {
    "lessonId": 201,
    "title": "Tổng quan kiến trúc MVC trong Spring Boot",
    "orderIndex": 1,
    "courseId": 1,
    "createdAt": "2026-05-28T01:25:00"
  }
}
```

### 📝 API 18: LẤY DANH SÁCH TOÀN BỘ BÀI HỌC THUỘC MỘT KHÓA HỌC

* **Endpoint:** `GET /api/v1/courses/{courseId}/lessons`
* **Content-Type:** `None`
* **Auth Required:** `Tuân theo cấu hình bảo mật khóa học cha quy định tại mục 3.2`

#### A. Request Specifications (Path Variables)

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `courseId` | Integer | Yes | ID khóa học mục tiêu cần lôi toàn bộ danh sách bài học ra |

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Truy vấn kiểm tra tính hợp pháp và tồn tại của khóa học cha dựa trên tham số đường dẫn `courseId`. Nếu không tìm thấy, báo lỗi dữ liệu `ResourceNotFoundException`.
2. **Step 2:** Áp dụng quy tắc kiểm duyệt trạng thái bảo mật tương tự mục 3.2. Nếu khóa học chưa được duyệt công khai ra cộng đồng (`PENDING` hoặc `HIDDEN`) thì hệ thống chỉ cho phép Admin hoặc chính Giảng viên chủ quản đi tiếp. Các học viên thông thường gọi vào sẽ bị ném lỗi `AccessDeniedException` ngay.
3. **Step 3:** Thực thi logic chính: Gọi hàm của tầng Repository thực hiện tìm kiếm toàn bộ các bài học có mã khóa ngoại liên kết trùng khớp với `courseId`, đồng thời ra lệnh cho hệ thống Database sắp xếp kết quả trả về theo thứ tự tăng dần của trường chỉ mục: `lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId)`.

🛠️ **Tầng Repository yêu cầu:**
```java
List<Lesson> findByCourse_CourseIdOrderByOrderIndexAsc(Integer courseId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy danh sách bài học thành công",
  "data": [
    {
      "lessonId": 201,
      "title": "Bài 1: Tổng quan kiến trúc MVC trong Spring Boot",
      "orderIndex": 1
    },
    {
      "lessonId": 202,
      "title": "Bài 2: Cấu hình và kết nối Cơ sở dữ liệu PostgreSQL",
      "orderIndex": 2
    }
  ]
}
```

### 📝 API 19: XEM THÔNG TIN CHI TIẾT BÀI HỌC

* **Endpoint:** `GET /api/v1/lessons/{lessonId}`
* **Content-Type:** `None`
* **Auth Required:** `Tài khoản học viên đã đăng ký tham gia khóa học hợp pháp, hoặc Admin / Giảng viên sở hữu khóa học.`

#### A. Request Specifications (Path Variables)

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `lessonId` | Integer | Yes | ID bài học cụ thể cần xem nội dung chi tiết bên trong |

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Tìm bài học trong DB bằng `lessonRepository.findById(lessonId)`. Nếu không tìm thấy bản ghi dữ liệu, ném ngoại lệ `ResourceNotFoundException` (HTTP Status 404).
2. **Step 2:** Hệ thống tự bóc tách ra `courseId` của khóa học cha chứa bài học này. Thực hiện kiểm tra tính hợp pháp:
   - Nếu là học viên, hệ thống gọi hàm `enrollmentRepository.existsByStudentIdAndCourseId(studentId, courseId)` để check xem học viên đã mua/đăng ký học khóa này chưa. Nếu chưa, ném lỗi `AccessDeniedException` (HTTP Status 403).
3. **Step 3:** Trả về đối tượng đầy đủ bao gồm thông tin cơ bản bài học đi kèm danh sách tất cả tài liệu PDF và Video liên kết trực thuộc bài học đó để người dùng học tập.

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy nội dung chi tiết bài học thành công",
  "data": {
    "lessonId": 201,
    "title": "Bài 1: Tổng quan kiến trúc MVC trong Spring Boot",
    "orderIndex": 1,
    "videos": [
      { "videoId": 1, "videoUrl": "https://youtube.com/watch?v=123", "type": "YOUTUBE" }
    ],
    "materials": [
      { "materialId": 1, "title": "Slide bài giảng MVC.pdf", "fileUrl": "https://link.com/slide.pdf" }
    ]
  }
}
```

### 📝 API 20: CẬP NHẬT NỘI DUNG BÀI HỌC

* **Endpoint:** `PUT /api/v1/lessons/{lessonId}`
* **Content-Type:** `application/json`
* **Auth Required:** `Quyền Giảng viên sở hữu khóa học (ROLE_INSTRUCTOR) hoặc Admin (ROLE_ADMIN)`

#### A. Request Specifications (Dữ liệu đầu vào)

- **Path Variables:** `lessonId` (ID bài học cần cập nhật thông tin)
- **Request Body:**
```json
{
  "title": "Bài 1: Cấu trúc MVC và các Annotation cơ bản trong Spring Boot",
  "orderIndex": 1
}
```

#### B. Business Logic & Step-by-Step Processing (Luồng xử lý nghiệp vụ)

1. **Step 1:** Tìm bài học bằng `lessonRepository.findById(lessonId)`. Nếu trống, quăng ngay lỗi `ResourceNotFoundException`.
2. **Step 2:** Kiểm tra xem người dùng thao tác có phải Admin hoặc chính Giảng viên đứng lớp khóa học cha đó không. Nếu không khớp, chặn đứng bằng lỗi `AccessDeniedException`.
3. **Step 3:** Tiến hành đè dữ liệu mới từ Request (`title`, `orderIndex`) vào thực thể cũ.
4. **Step 4:** Lưu cập nhật xuống PostgreSQL thông qua `lessonRepository.save(lesson)`.

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Cập nhật bài học thành công!",
  "data": {
    "lessonId": 201,
    "title": "Bài 1: Cấu trúc MVC và các Annotation cơ bản trong Spring Boot",
    "orderIndex": 1
  }
}
```

### 📝 API 21: XÓA BÀI HỌC KHỎI HỆ THỐNG

* **Endpoint:** `DELETE /api/v1/lessons/{lessonId}`
* **Content-Type:** `None`
* **Auth Required:** `Quyền Giảng viên sở hữu khóa học (ROLE_INSTRUCTOR)` hoặc `Admin (ROLE_ADMIN)`

#### A. Request Specifications (Path Variables)


| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `lessonId` | Integer | Yes | ID bài học mục tiêu cần xóa vĩnh viễn khỏi hệ thống |

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm bài học:** Tìm bài học bằng `lessonRepository.findById(lessonId)`. Nếu không tìm thấy bản ghi dữ liệu, ném lỗi `ResourceNotFoundException`.
2. **Kiểm tra quyền sở hữu:** Kiểm tra tính chủ sở hữu tương tự mục 4.1 để đảm bảo giảng viên lạ không thể sang xóa trộm bài học của giảng viên khác.
3. **Xóa dữ liệu:** Thực hiện lệnh xóa vĩnh viễn đối tượng thực thể khỏi database PostgreSQL bằng cách gọi hàm `lessonRepository.deleteById(lessonId)`.

🛠️ **Yêu cầu tầng Repository:**
Sử dụng hàm có sẵn của Spring Data JPA:
```java
void deleteById(Integer id);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Bài học đã được xóa thành công khỏi hệ thống."
}
```

---

### 📝 API 22: HỌC VIÊN ĐÁNH DẤU HOÀN THÀNH BÀI HỌC

* **Endpoint:** `POST /api/v1/lessons/{lessonId}/complete`
* **Content-Type:** `None`
* **Auth Required:** `Học viên có vai trò ROLE_STUDENT`

#### A. Request Specifications (Path Variables)


| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `lessonId` | Integer | Yes | ID bài học cụ thể mà học viên vừa học xong và muốn tích hoàn thành |

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm bài học:** Tìm kiếm đối tượng thực thể bài học dựa theo tham số mã truyền vào `lessonId`. Nếu không tìm thấy bản ghi dữ liệu, ném ngoại lệ `ResourceNotFoundException` (HTTP Status 404). Trích xuất thông tin mã khóa học cha `courseId` từ thuộc tính liên kết của bài học này.
2. **Trích xuất thông tin:** Bóc tách mã định danh học viên `studentId` từ Token phiên làm việc hiện tại.
3. **Xác thực đăng ký học (Enrollment Verification):** Gọi `enrollmentRepository.existsByStudentIdAndCourseId(studentId, courseId)` để kiểm tra học viên này đã đăng ký tham gia học khóa học này một cách hợp pháp chưa. Nếu chưa đăng ký, lập tức chặn quyền truy cập và ném ngoại lệ hệ thống `AccessDeniedException` (HTTP Status 403 Forbidden).
4. **Kiểm tra lịch sử tiến độ:** Gọi `lessonProgressRepository.findByStudentIdAndLessonId(studentId, lessonId)` nhằm rà soát lịch sử tiến độ học tập:
   * **Nếu đã tồn tại bản ghi:** Giữ nguyên trạng thái dữ liệu cũ để tránh phát sinh bản ghi trùng lặp rác hệ thống.
   * **Nếu chưa từng tồn tại:** Khởi tạo một thực thể tiến độ học tập `LessonProgress` mới hoàn toàn, gán cấu trúc khóa ngoại với `studentId`, `lessonId`, gán cờ xác thực hoàn thành `isCompleted = true` và cấu hình thời gian tự động gán bằng giờ hệ thống thông qua hàm `@PrePersist` của `BaseEntity`.
5. **Lưu trữ tiến độ:** Thực hiện lưu dữ liệu tiến độ mới xuống database qua hàm `lessonProgressRepository.save(progress)`.

🛠️ **Yêu cầu tầng Repository:**
```java
Optional<LessonProgress> findByStudentIdAndLessonId(Integer studentId, Integer lessonId);
boolean existsByStudentIdAndCourseId(Integer studentId, Integer courseId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Đánh dấu hoàn thành bài học thành công!",
  "data": {
    "progressId": 5001,
    "studentId": 1,
    "lessonId": 201,
    "isCompleted": true,
    "completedAt": "2026-05-28T01:30:00"
  }
}
```

### 📝 API 23: XEM TỶ LỆ PHẦN TRĂM TIẾN ĐỘ HỌC TẬP TRONG KHÓA HỌ

* **Endpoint:** `GET /api/v1/courses/{courseId}/progress`
* **Content-Type:** `None`
* **Auth Required:** `Học viên có vai trò ROLE_STUDENT`

#### A. Request Specifications (Path Variables)


| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `courseId` | Integer | Yes | ID khóa học muốn tính toán tổng tiến độ học tập tích lũy |

#### B. Business Logic & Step-by-Step Processing

1. **Trích xuất thông tin:** Trích xuất định danh mã học viên `studentId` từ thông tin token phiên làm việc hiện hành.
2. **Đếm tổng số bài học:** Yêu cầu hệ thống đếm tổng số lượng bài học hiện có được thiết lập cấu hình trong khóa học này bằng cách gọi hàm `lessonRepository.countByCourse_CourseId(courseId)`, đặt kết quả vào biến dữ liệu `totalLessons`.
3. **Xử lý ngoại lệ chia cho 0:** Nếu biến số lượng `totalLessons == 0`, lập tức trả về đối tượng phản hồi với tỷ lệ hoàn thành mặc định bằng `0%` để tránh lỗi sập hệ thống do chia cho số không (`ArithmeticException`).
4. **Thống kê số bài đã học:** Nếu `totalLessons > 0`, gọi hàm xử lý đếm nâng cao từ tầng Repository `lessonProgressRepository.countCompletedLessonsByStudentIdAndCourseId(studentId, courseId)` để thống kê tổng số lượng bài học mà học viên cụ thể này đã thực hiện tích chọn hoàn thành thành công trong phạm vi của khóa học cha, lưu vào biến `completedLessons`.
5. **Tính toán tỷ lệ phần trăm:** Thực hiện tính toán tỷ lệ phần trăm tiến độ học tập tích lũy hoàn thành khóa học theo công thức toán học chuẩn:
   $$\text{Tỷ lệ phần trăm (\%)} = \left(\frac{\text{completedLessons}}{\text{totalLessons}}\right) \times 100$$
6. **Đóng gói phản hồi:** Tổng hợp toàn bộ các tham số tính toán được để đóng gói cấu trúc vào một đối tượng dữ liệu đầu ra chuyên biệt `ProgressResponseDTO` phản hồi về Client.

🛠️ **Yêu cầu tầng Repository:**

*Trong lớp `LessonRepository`:*
```java
Long countByCourse_CourseId(Integer courseId); 
```

*Trong lớp `LessonProgressRepository` viết câu Query JPQL:*
```java
@Query("SELECT COUNT(lp) FROM LessonProgress lp JOIN lp.lesson l WHERE lp.studentId = :studentId AND l.course.courseId = :courseId AND lp.isCompleted = true")
Long countCompletedLessonsByStudentIdAndCourseId(Integer studentId, Integer courseId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Tính toán tiến độ học tập thành công",
  "data": {
    "completedLessons": 4,
    "totalLessons": 10,
    "progressPercentage": 40.0
  }
}
```

---

## 5. PHÂN HỆ QUẢN LÝ VIDEO (MODULE E)

### 📝 API 24: UPLOAD VIDEO CHO BÀI HỌC (FILE VẬT LÝ)

* **Endpoint:** `POST /api/v1/lessons/{lessonId}/videos`
* **Content-Type:** `multipart/form-data` (Bắt buộc dùng kiểu này khi có upload File vật lý)
* **Auth Required:** `Quyền Giảng viên sở hữu khóa học (ROLE_INSTRUCTOR)` hoặc `Admin (ROLE_ADMIN)`

#### A. Request Specifications (Dữ liệu đầu vào)

**Path Variables:** `lessonId` (Xác định video này thuộc về bài học nào)

**Form Data (Tham số truyền file):**


| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `file` | MultipartFile | Yes | File video vật lý chọn từ máy tính (định dạng mp4, avi...) |

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm bài học:** Tìm bài học cha qua `lessonRepository.findById(lessonId)`. Nếu rỗng, ném lỗi `ResourceNotFoundException`.
2. **Kiểm tra quyền sở hữu:** Kiểm tra tính chính chủ tương tự mục 4.1 để tránh giảng viên khác upload lén file vào bài giảng.
3. **Tải tập tin lên Cloud:** Backend tiếp nhận file từ Form-Data, gọi sang thư viện bên thứ 3 (như Cloudinary, Amazon S3...) để upload file lên đám mây và nhận về một đường link URL lưu trữ công khai.
4. **Khởi tạo dữ liệu:** Khởi tạo thực thể Video mới, gán `videoUrl = đường_link_nhận_được`, gán loại định dạng `type = "NATIVE"` và gán khóa ngoại liên kết tới bài học cha `Lesson`.
5. **Lưu trữ dữ liệu:** Gọi hàm `videoRepository.save(video)` để lưu cấu trúc vào DB PostgreSQL.

🛠️ **Yêu cầu tầng Repository:**
Sử dụng hàm cơ bản của Spring Data JPA:
```java
Video save(Video video);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 201 Created)**

```json
{
  "success": true,
  "message": "Upload video bài giảng thành công!",
  "data": {
    "videoId": 10,
    "videoUrl": "https://s3.amazonaws.com/elearning/videos/lesson1_mvc.mp4",
    "type": "NATIVE",
    "lessonId": 201
  }
}
```

---

### 📝 API 25: THÊM VIDEO YOUTUBE VÀO BÀI HỌC

* **Endpoint:** `POST /api/v1/lessons/{lessonId}/videos/youtube`
* **Content-Type:** `application/json`
* **Auth Required:** `Quyền Giảng viên sở hữu khóa học (ROLE_INSTRUCTOR)` hoặc `Admin (ROLE_ADMIN)`

#### A. Request Specifications (Dữ liệu đầu vào từ Body)


| Field Name | Type | Required | Validation Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `videoUrl` | String | Yes | Format: URL | Đường dẫn liên kết của video trên nền tảng Youtube |

**Example Request Body:**
```json
{
  "videoUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}
```

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm bài học:** Tìm bài học cha qua `lessonRepository.findById(lessonId)`. Nếu không tồn tại, ném lỗi `ResourceNotFoundException`.
2. **Kiểm tra quyền sở hữu:** Kiểm tra điều kiện phân quyền chủ sở hữu khóa học cha tương tự mục 4.1.
3. **Khởi tạo dữ liệu:** Khởi tạo thực thể Video mới, gán trực tiếp chuỗi URL người dùng cung cấp vào trường `videoUrl`, thiết lập cấu hình định dạng loại video là `type = "YOUTUBE"`, gán liên kết quan hệ thực thể với bài học cha `Lesson`.
4. **Lưu trữ dữ liệu:** Đồng bộ thông tin lưu trữ xuống Database bằng lệnh `videoRepository.save(video)`.

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 201 Created)**

```json
{
  "success": true,
  "message": "Nhúng link video Youtube thành công!",
  "data": {
    "videoId": 11,
    "videoUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "type": "YOUTUBE",
    "lessonId": 201
  }
}
```
### 📝 API 26: XÓA VIDEO KHỎI BÀI HỌC

* **Endpoint:** `DELETE /api/v1/videos/{videoId}`
* **Content-Type:** `None`
* **Auth Required:** `Quyền Giảng viên sở hữu khóa học (ROLE_INSTRUCTOR)` hoặc `Admin (ROLE_ADMIN)`

#### A. Request Specifications (Path Variables)



| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `videoId` | Integer | Yes | ID của bản ghi video mục tiêu cần xóa vĩnh viễn |

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm video:** Tìm thực thể video trong DB qua `videoRepository.findById(videoId)`. Nếu trống, quăng lỗi `ResourceNotFoundException`.
2. **Kiểm tra bảo mật:** Hệ thống truy vết ngược từ `video` $\rightarrow$ lấy ra bài học $\rightarrow$ lấy ra khóa học cha $\rightarrow$ lấy ra giảng viên tạo để check quyền chủ quản. Nếu không phải chủ sở hữu hoặc không phải Admin, chặn đứng bằng lỗi `AccessDeniedException`.
3. **Xóa dữ liệu vĩnh viễn:** Gọi hàm từ tầng lưu trữ xử lý xóa vĩnh viễn: `videoRepository.deleteById(videoId)`.
   *(Mẹo mở rộng: Nếu video thuộc loại `NATIVE`, Backend nên viết code gọi lệnh xóa cả file vật lý trên đám mây Cloudinary/S3 để tránh tốn dung lượng lưu trữ rác).*

🛠️ **Yêu cầu tầng Repository:**
Sử dụng hàm mặc định của Spring Data JPA:
```java
void deleteById(Integer id);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Video bài giảng đã được xóa thành công khỏi hệ thống."
}
```

---

## 6. PHÂN HỆ TÀI LIỆU ĐỌC - SLIDE (MODULE G)

### 📝 API 27: UPLOAD TÀI LIỆU PDF CHO BÀI HỌC

* **Endpoint:** `POST /api/v1/lessons/{lessonId}/materials`
* **Content-Type:** `multipart/form-data`
* **Auth Required:** `Quyền Giảng viên sở hữu khóa học (ROLE_INSTRUCTOR)` hoặc `Admin (ROLE_ADMIN)`

#### A. Request Specifications (Dữ liệu đầu vào)

**Path Variables:** `lessonId` (Xác định tài liệu này thuộc về bài học nào)

**Form Data (Tham số truyền dữ liệu):**



| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `title` | String | Yes | Tiêu đề tên của tài liệu (Ví dụ: Slide chương 1, Giáo trình đọc thêm...) |
| `file` | MultipartFile | Yes | File tài liệu định dạng PDF vật lý đẩy từ máy tính lên |

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm bài học:** Tìm bài học cha qua `lessonRepository.findById(lessonId)`. Nếu không thấy, ném lỗi `ResourceNotFoundException`.
2. **Kiểm tra quyền sở hữu:** Kiểm tra điều kiện phân quyền chủ sở hữu khóa học cha tựa mục 4.1 để bảo vệ tài nguyên hệ thống.
3. **Xử lý tập tin PDF:** Tiếp nhận file PDF, đẩy file lên lưu trữ trên dịch vụ đám mây công cộng (Cloudinary, S3...) và lấy về đường dẫn URL công khai.
4. **Khởi tạo dữ liệu:** Khởi tạo thực thể `ReadingMaterial` mới, nạp thông tin trường `title` người dùng gõ, trường `fileUrl = đường_link_vừa_nhận_được`, cấu hình liên kết khóa ngoại trỏ tới bài học cha `Lesson`.
5. **Lưu trữ dữ liệu:** Thực hiện lệnh lưu dữ liệu bằng cách gọi hàm `readingMaterialRepository.save(material)`.

🛠️ **Yêu cầu tầng Repository:**
Sử dụng hàm cơ bản của Spring Data JPA:
```java
ReadingMaterial save(ReadingMaterial material);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 201 Created)**

```json
{
  "success": true,
  "message": "Đẩy tài liệu PDF bài học lên hệ thống thành công!",
  "data": {
    "materialId": 301,
    "title": "Tài liệu hướng dẫn cấu hình Spring Security cơ bản.pdf",
    "fileUrl": "https://s3.amazonaws.com/elearning/materials/security_guide.pdf",
    "lessonId": 201
  }
}
```

---

### 📝 API 28: LẤY DANH SÁCH TÀI LIỆU ĐỌC CỦA BÀI HỌC

* **Endpoint:** `GET /api/v1/lessons/{lessonId}/materials`
* **Content-Type:** `None`
* **Auth Required:** `Học viên đã đăng ký tham gia khóa học hợp pháp`, hoặc `Admin` / `Giảng viên sở hữu`

#### A. Request Specifications (Path Variables)



| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `lessonId` | Integer | Yes | ID bài học cụ thể cần lôi ra toàn bộ file PDF liên kết trực thuộc |

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm bài học:** Kiểm tra tính tồn tại của bài học cha qua `lessonRepository.findById(lessonId)`. Nếu trống, ném lỗi `ResourceNotFoundException`.
2. **Kiểm tra quyền truy cập:** Kiểm tra điều kiện bảo mật quyền học tập tương tự mục 4.2. Nếu là học viên lạ chưa đăng ký khóa học, lập tức ném lỗi chặn lại bằng `AccessDeniedException`.
3. **Truy vấn danh sách:** Gọi hàm xử lý từ tầng Repository tìm toàn bộ các bản ghi tài liệu có mã khóa ngoại trùng với bài học: `readingMaterialRepository.findByLesson_LessonId(lessonId)`.

🛠️ **Yêu cầu tầng Repository:**
```java
List<ReadingMaterial> findByLesson_LessonId(Integer lessonId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy danh sách tài liệu đọc thành công",
  "data": [
    {
      "materialId": 301,
      "title": "Tài liệu hướng dẫn cấu hình Spring Security cơ bản.pdf",
      "fileUrl": "https://link.com/security_guide.pdf"
    }
  ]
}
```

### 📝 API 29: XÓA TÀI LIỆU ĐỌC KHỎI BÀI HỌC

* **Endpoint:** `DELETE /api/v1/materials/{materialId}`
* **Content-Type:** `None`
* **Auth Required:** `Quyền Giảng viên sở hữu khóa học (ROLE_INSTRUCTOR)` hoặc `Admin (ROLE_ADMIN)`

#### A. Request Specifications (Path Variables)



| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `materialId` | Integer | Yes | ID duy nhất của bản ghi tài liệu PDF mục tiêu cần xóa khỏi hệ thống |

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm tài liệu:** Tìm thực thể tài liệu đọc trong DB qua `readingMaterialRepository.findById(materialId)`. Nếu trống, ném lỗi `ResourceNotFoundException`.
2. **Kiểm tra bảo mật:** Hệ thống rà soát ngược từ tài liệu đọc $\rightarrow$ lấy ra bài học $\rightarrow$ lấy ra khóa học cha $\rightarrow$ lấy ra giảng viên tạo để đối sánh quyền chủ quản. Nếu không có quyền, ném lỗi `AccessDeniedException` chặn lại.
3. **Xóa dữ liệu:** Gọi hàm từ tầng lưu trữ thực thi lệnh xóa vĩnh viễn bản ghi: `readingMaterialRepository.deleteById(materialId)`.

🛠️ **Yêu cầu tầng Repository:**
Sử dụng hàm cơ bản mặc định của Spring Data JPA:
```java
void deleteById(Integer id);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Tài liệu đọc đã được xóa thành công khỏi bài học."
}
```

---

## 7. PHÂN HỆ GHI DANH - ĐĂNG KÝ HỌC (MODULE H)

### 📝 API 30: HỌC VIÊN ĐĂNG KÝ THAM GIA KHÓA HỌC MỚI

* **Endpoint:** `POST /api/v1/courses/{courseId}/enroll`
* **Content-Type:** `None`
* **Auth Required:** `Học viên hệ thống mang vai trò ROLE_STUDENT`

#### A. Request Specifications (Path Variables)



| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `courseId` | Integer | Yes | Mã khóa học mục tiêu mà học viên muốn click đăng ký ghi danh |

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm khóa học:** Tìm kiếm kiểm tra tính tồn tại của khóa học cha qua `courseRepository.findById(courseId)`. Nếu không tìm thấy bản ghi, ném ngoại lệ `ResourceNotFoundException`.
2. **Trích xuất thông tin:** Bóc tách thông tin mã học viên `studentId` từ Token phiên làm việc hiện tại.
3. **Kiểm tra trùng lặp ghi danh:** Kiểm tra trùng lặp (tránh việc học viên bấm nút đăng ký liên tục sinh ra trùng dữ liệu rác hệ thống): Gọi `enrollmentRepository.existsByStudentIdAndCourseId(studentId, courseId)`. Nếu kết quả trả về là `true`, lập tức chặn tiến trình lại và ném ra ngoại lệ nghiệp vụ hệ thống `AlreadyEnrolledException` (Trả về HTTP Status 400 Bad Request).
4. **Khởi tạo dữ liệu:** Thực thi logic chính: Khởi tạo thực thể ghi danh `Enrollment` mới hoàn toàn, liên kết cấu trúc khóa ngoại với `studentId`, `courseId`, thời gian ghi danh tự động gán bằng giờ hệ thống thông qua hàm tự tăng `@PrePersist` của `BaseEntity`.
5. **Lưu trữ dữ liệu:** Gọi hàm lưu dữ liệu từ tầng Repository: `enrollmentRepository.save(enrollment)`.

🛠️ **Yêu cầu tầng Repository:**
```java
boolean existsByStudentIdAndCourseId(Integer studentId, Integer courseId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 201 Created)**

```json
{
  "success": true,
  "message": "Đăng ký khóa học thành công! Chúc bạn có trải nghiệm học tập vui vẻ.",
  "data": {
    "enrollmentId": 7001,
    "studentId": 1,
    "courseId": 1,
    "createdAt": "2026-05-28T01:35:00"
  }
}
```

🔴 **Case 2: Error - Already Enrolled (HTTP Status 400 Bad Request)**

```json
{
  "success": false,
  "errorCode": "ALREADY_ENROLLED",
  "message": "Học viên cố tình gửi yêu cầu đăng ký tham gia vào một khóa học mà họ đã ghi danh từ trước!"
}
```

---

### 📝 API 31: DANH SÁCH CÁC KHÓA HỌC MÀ HỌC VIÊN ĐÃ ĐĂNG KÝ HỌC

* **Endpoint:** `GET /api/v1/enrollments/my-courses`
* **Content-Type:** `None`
* **Auth Required:** `Học viên hệ thống mang vai trò ROLE_STUDENT`

#### A. Request Specifications (Dữ liệu đầu vào)

API lấy toàn bộ danh sách các khóa học mà học viên hiện tại đã đăng ký mua/tham gia, thông tin mã định danh học viên tự động bóc ngầm từ Token.

#### B. Business Logic & Step-by-Step Processing

1. **Trích xuất thông tin:** Trích xuất mã định danh người dùng `currentStudentId` từ Token xác thực.
2. **Truy vấn danh sách ghi danh:** Gọi hàm xử lý truy vấn dữ liệu từ tầng Repository để lôi ra toàn bộ các bản ghi ghi danh của học viên này: `enrollmentRepository.findByStudentId(currentStudentId)`.
3. **Đóng gói dữ liệu đầu ra:** Từ danh sách ghi danh tìm được, bóc tách lấy ra thông tin danh sách các thực thể `Course` liên kết để đóng gói trả về cho Client hiển thị trên màn hình Tab "Khóa học của tôi".

🛠️ **Yêu cầu tầng Repository:**
```java
List<Enrollment> findByStudentId(Integer studentId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy danh sách khóa học đã ghi danh thành công",
  "data": [
    {
      "enrollmentId": 7001,
      "course": {
        "courseId": 1,
        "title": "Lập trình Java Spring Boot Web chuyên nghiệp",
        "thumbnailUrl": "https://link.com/java.png"
      },
      "enrolledAt": "2026-05-27T15:00:00"
    }
  ]
}
```

### 📝 API 32: GIẢNG VIÊN TRA CỨU DANH SÁCH HỌC VIÊN TRONG KHÓA HỌC

* **Endpoint:** `GET /api/v1/courses/{courseId}/students`
* **Content-Type:** `None`
* **Auth Required:** `Quyền Giảng viên chủ quản khóa học (ROLE_INSTRUCTOR)` hoặc `Admin (ROLE_ADMIN)`

#### A. Request Specifications (Path Variables)



| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `courseId` | Integer | Yes | ID khóa học mục tiêu giảng viên cần xem danh sách lớp học |

#### B. Business Logic & Step-by-Step Processing

1. **Tìm kiếm khóa học:** Kiểm tra tính tồn tại của khóa học cha qua `courseRepository.findById(courseId)`. Nếu trống, ném lỗi `ResourceNotFoundException`.
2. **Kiểm tra quyền sở hữu:** Kiểm tra điều kiện phân quyền chủ sở hữu khóa học để tránh giảng viên khác vào xem trộm thông tin danh sách học viên lớp mình.
3. **Truy vấn danh sách ghi danh:** Gọi hàm truy vấn từ `enrollmentRepository.findByCourse_CourseId(courseId)` để lôi ra toàn bộ danh sách các bản ghi ghi danh của lớp học này.
4. **Ánh xạ và đóng gói:** Duyệt qua danh sách, lấy thông tin của các học viên liên kết (`fullName`, `email`, `phone`), thực hiện đóng gói chuyển đổi cấu trúc sang `UserDTO` sạch sẽ để trả về hiển thị tại màn hình quản lý lớp học của Giảng viên.

🛠️ **Yêu cầu tầng Repository:**
```java
List<Enrollment> findByCourse_CourseId(Integer courseId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy danh sách học viên trực thuộc khóa học thành công",
  "data": [
    {
      "studentId": 1,
      "fullName": "Nguyen Van A Học Viên",
      "email": "studenta@gmail.com",
      "enrolledAt": "2026-05-27T15:00:00"
    }
  ]
}
```

---

## 8. PHÂN HỆ MÀN HÌNH TỔNG QUAN (MODULE I)

### 📝 API 33: DASHBOARD TỔNG QUAN HỌC VIÊN

* **Endpoint:** `GET /api/v1/dashboard/student`
* **Content-Type:** `None`
* **Auth Required:** `Tài khoản học viên có vai trò ROLE_STUDENT`

#### A. Request Specifications (Dữ liệu đầu vào)

API lấy thông tin số liệu thống kê cá nhân của học viên, mã định danh người dùng bóc ngầm từ Token phiên làm việc.

#### B. Business Logic & Step-by-Step Processing

1. **Trích xuất thông tin:** Trích xuất định danh `studentId` từ thông tin token xác thực.
2. **Thống kê khóa học:** Thống kê số lượng khóa học đã đăng ký tham gia bằng cách gọi lệnh: `enrollmentRepository.countByStudentId(studentId)`.
3. **Thống kê tiến độ:** Thống kê tổng số lượng bài học đã tích chọn hoàn thành bằng cách gọi hàm xử lý từ tầng lưu trữ: `lessonProgressRepository.countByStudentIdAndIsCompletedTrue(studentId)`.
4. **Đóng gói phản hồi:** Tổng hợp các số liệu thu thập được để đóng gói cấu trúc vào một đối tượng dữ liệu đầu ra chuyên biệt phản hồi về cho giao diện hiển thị màn hình Dashboard cá nhân của Học viên.

🛠️ **Yêu cầu tầng Repository:**

*Trong lớp `EnrollmentRepository`:*
```java
Long countByStudentId(Integer studentId);
```

*Trong lớp `LessonProgressRepository`:*
```java
Long countByStudentIdAndIsCompletedTrue(Integer studentId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy số liệu tổng quan Dashboard học viên thành công",
  "data": {
    "enrolledCoursesCount": 3,
    "completedLessonsCount": 14
  }
}
```

---

### 📝 API 34: DASHBOARD TỔNG QUAN GIẢNG VIÊN

* **Endpoint:** `GET /api/v1/dashboard/instructor`
* **Content-Type:** `None`
* **Auth Required:** `Tài khoản giảng viên hệ thống có vai trò ROLE_INSTRUCTOR`

#### A. Request Specifications (Dữ liệu đầu vào)

Thống kê số liệu kinh doanh, dạy học của riêng giảng viên, mã định danh bóc ngầm từ Token.

#### B. Business Logic & Step-by-Step Processing

1. **Trích xuất thông tin:** Trích xuất định danh mã `instructorId` từ Token phiên làm việc hiện tại.
2. **Thống kê khóa học:** Thống kê tổng số lượng khóa học do chính mình tạo lập: Gọi `courseRepository.countByInstructor_UserId(instructorId)`.
3. **Thống kê học viên:** Thống kê tổng số lượng học viên đã đăng ký tham gia vào tất cả các khóa học của mình: Gọi hàm đếm tùy chỉnh nâng cao từ `enrollmentRepository.countTotalStudentsByInstructorId(instructorId)`.
4. **Đóng gói phản hồi:** Tổng hợp dữ liệu đóng gói trả về cho Client vẽ biểu đồ thống kê.

🛠️ **Yêu cầu tầng Repository:**

*Trong lớp `CourseRepository`:*
```java
Long countByInstructor_UserId(Integer instructorId);
```

*Trong lớp `EnrollmentRepository` viết câu Query JPQL nâng cao:*
```java
@Query("SELECT COUNT(e) FROM Enrollment e JOIN e.course c WHERE c.instructor.userId = :instructorId")
Long countTotalStudentsByInstructorId(Integer instructorId);
```

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy số liệu tổng quan Dashboard giảng viên thành công",
  "data": {
    "myTotalCourses": 5,
    "myTotalStudentsEnrolled": 142
  }
}
```

---

### 📝 API 35: DASHBOARD HỆ THỐNG DÀNH CHO QUẢN TRỊ VIÊN (ADMIN)

* **Endpoint:** `GET /api/v1/dashboard/admin`
* **Content-Type:** `None`
* **Auth Required:** `Tài khoản quản trị viên tối cao hệ thống ROLE_ADMIN`

#### A. Request Specifications (Dữ liệu đầu vào)

Admin có quyền tối cao xem toàn bộ số liệu vĩ mô của dự án nên không cần tham số điều kiện gì lọc cả.

#### B. Business Logic & Step-by-Step Processing

1. **Đếm tổng người dùng:** Đếm tổng số lượng người dùng đang đăng ký hoạt động trong hệ thống bằng lệnh: `userRepository.count()`.
2. **Đếm tổng khóa học:** Đếm tổng số lượng khóa học hiện có trong toàn bộ DB: Gọi `courseRepository.count()`.
3. **Đếm tổng lượt ghi danh:** Đếm tổng số lượng giao dịch đăng ký ghi danh thành công: Gọi `enrollmentRepository.count()`.
4. **Đếm tổng hợp số liệu:** Tổng hợp 3 số liệu vĩ mô thu thập được đóng gói trả về Client để hiển thị các khối thẻ số liệu tại trang chủ trang quản trị Admin.

🛠️ **Yêu cầu tầng Repository:**
Sử dụng trực tiếp hàm cơ bản sẵn có của Spring Data JPA không cần viết thêm:
```java
long count();
```
*(Áp dụng trên cả 3 lớp `UserRepository`, `CourseRepository`, và `EnrollmentRepository`).*

#### C. Response Specifications (Dữ liệu đầu ra)

🟢 **Case 1: Success (HTTP Status 200 OK)**

```json
{
  "success": true,
  "message": "Lấy số liệu tổng quan hệ thống Admin thành công",
  "data": {
    "totalUsersInSystem": 1024,
    "totalCoursesPublished": 45,
    "totalEnrollmentsCount": 3582
  }
}
```
