# 📘 README — Backend (Express + TypeScript + Prisma)

## 🚀 Giới thiệu

Dự án Backend sử dụng:

- **Express** (REST API)
- **TypeScript**
- **Prisma ORM** (MySQL)
- **Module Architecture** (`src/modules/*`)
- **Common Utilities** (`src/common/*`)
- **ESLint + Prettier** để format & lint code

---

## 📁 Cấu trúc thư mục

Cấu trúc thư mục tham khảo:

```
app_be/
├── prisma/
│   ├── schema.prisma          # Định nghĩa schema database
│   └── migrations/            # Các file migration
│
├── src/
│   ├── index.ts               # Entry point
│   │
│   ├── common/                # Utilities dùng chung
│   │   ├── middlewares/       # Middleware (auth, error, validation...)
│   │   ├── errors/            # Custom error classes
│   │   ├── utils/             # Helper functions
│   │   └── types/             # TypeScript types/interfaces
│   │
│   └── modules/               # Các module chức năng
│       ├── user/              # Module người dùng
│       │   ├── user.route.ts       # Route definitions
│       │   ├── user.controller.ts  # Xử lý HTTP requests
│       │   ├── user.service.ts     # Business logic
│       │   ├── user.schema.ts      # Validation schemas (Zod)
│       │   └── user.dto.ts         # Data Transfer Objects
│       │
│       └── auth/              # Module xác thực
│           ├── auth.route.ts
│           ├── auth.controller.ts
│           ├── auth.service.ts
│           ├── auth.schema.ts
│           └── auth.dto.ts
│
├── .env                       # Environment variables
├── .eslintrc.js               # ESLint config
├── .prettierrc                # Prettier config
├── tsconfig.json              # TypeScript config
└── package.json
```

## 🛠️ Cài đặt & Chạy dự án

Cài dependencies:

```
npm install
```

Chạy development:

```
npm run dev
```

Build production:

```
npm run build
```

Chạy server:

```
npm start
```

## 🗃️ Database & Prisma

Cấu hình MySQL trong file .env

```
DATABASE_URL="mysql://USER:PASSWORD@localhost:3306/DATABASE_NAME"
```

Ví dụ:

```
DATABASE_URL="mysql://root:123456@localhost:3306/appdb"
```

Generate Prisma Client: Dùng lệnh này khi bạn thay đổi schema.prisma để Prisma tạo lại client TypeScript.

```
npx prisma generate
```

Sau khi chạy, Prisma Client sẽ được tạo trong thư mục `generated/prisma/` hoặc đường dẫn bạn khai báo trong `schema.prisma`)

Tạo migration (khuyến khích – dùng cho thực tế), lệnh này tạo file migration SQL và apply vào database.

```
npx prisma migrate dev --name init
```

Trong đó `init` là tên migration (bạn có thể đặt tên khác)

Prisma sẽ:

- tạo thư mục `prisma/migrations/<timestamp>_init/`
- chứa file SQL mô tả thay đổi database
- tự apply migration lên database
- tự generate lại Prisma Client

## 🎨 Code Quality & Formatting

### 📋 Quy tắc chung

- ✅ Code phải pass ESLint trước khi commit
- ✅ Code phải được format với Prettier
- ✅ Tuân thủ coding conventions của dự án
- ✅ Không disable ESLint rules trừ khi thực sự cần thiết

---

### 🔍 Lint và Format

Kiểm tra lỗi ESLint:

```
npm run lint
```

Tự động sửa lỗi ESLint:

```
npm run lint:fix
```

Format code với Prettier

```
npm run format
```
