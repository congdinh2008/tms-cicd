# ----- Giai đoạn 1: Build -----
# Sử dụng một image Node.js để build ứng dụng
FROM node:24-alpine AS build

# Thiết lập thư mục làm việc trong container
WORKDIR /app

# Sao chép các file package.json và package-lock.json
COPY package*.json ./

# Cài đặt các dependencies
RUN npm install

# Sao chép toàn bộ mã nguồn của ứng dụng
COPY . .

# Build ứng dụng React để tạo ra các file tĩnh
RUN npm run build

# ----- Giai đoạn 2: Serve -----
# Sử dụng một máy chủ web nhẹ (Nginx) để phục vụ các file tĩnh
FROM nginx:stable-alpine

# Sao chép các file đã build từ giai đoạn 'build' vào thư mục phục vụ của Nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Sao chép file cấu hình Nginx (tùy chọn nhưng khuyến khích)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 để bên ngoài có thể truy cập
EXPOSE 80

# Lệnh để khởi động máy chủ Nginx khi container chạy
CMD ["nginx", "-g", "daemon off;"]