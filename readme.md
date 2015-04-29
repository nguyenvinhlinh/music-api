## Giới Thiệu 
Dự án này là mã nguồn mở. Thời gian này, chỉ có hai nguồn được phát triển trước
đó là ZingMp3 và Nhaccuatui, các nguồn nhạc sẽ được phát triển tùy theo nhu cầu
của lập trình viên.  

Các thông tin bài hát bao gồm `name`, `singers`, `lyrics`, `song's page` và đặc
biệt  `song's source` để download.  


## Nó làm việc thế nào ?  
Cơ bản, service này gửi yêu cầu đến nguồn nhạc gốc (server VNG, Nhaccuatio), sau
khi nhận phản hồi từ server, service này sẽ phân tích phản hồi. Sau cùng,
service gửi json object bao gồm các thông tin bài hát đến các máy khách.  

Hiện tại, service đang được deploy ở Mỹ bởi Heroku, tại vì IP filter áp dụng bới
VNG, sẽ có rất nhiều bài hát không tìm được. Tôi sẽ thử nghiệm sử dụng VPN đặt ở
Mỹ, kết quả rất hạn chế.  

Tin tốt là Nhaccuatui có vẻ rất hào phóng. Họ cho phép truy cập từ các IP nước
ngoài. Điều này có nghĩa là các bạn có thể khai thác nhiều bài hát hơn.
## Cách sử dụng   
- The official website: [silverlink.herokuapp.com](http://silverlink.herokuapp.com)
- Gửi request đến  [http://silverlink.herokuapp.com/api](http://silverlink.herokuapp.com/api), và dịch vụ sẽ trả lại
  kết quả ở json object.  
- Có 3 parameter cần quan tâm:  
-- source: nguồn nhạc (zing mp3 = 1, nhaccuatui = 2) - bắt buộc   
-- keyword: từ khóa  - bắt buộc   
-- number: số lượng  - không bắt buộc . Tối đa là 60 cho ZingMp3 và 111 cho
   Nhaccuatui.  
- Ví Dụ :   
[http://silverlink.herokuapp.com/api?source=1&keyword=em&number=5](http://silverlink.herokuapp.com/api?source=1&keyword=em&number=5)   
[http://silverlink.herokuapp.com/api?source=1&keyword=em yeu&number=5](http://silverlink.herokuapp.com/api?source=1&keyword=em yeu&number=5)  
[http://silverlink.herokuapp.com/api?source=1&keyword=em%20cua%20ngay%20hom%20qua](http://silverlink.herokuapp.com/api?source=1&keyword=em%20cua%20ngay%20hom%20qua)  
[http://silverlink.herokuapp.com/api?source=2&keyword=em&number=5](http://silverlink.herokuapp.com/api?source=2&keyword=em&number=5)
