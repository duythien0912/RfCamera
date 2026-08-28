#!/usr/bin/env python3
"""
generate_20_new_articles.py
Generates 20 high-quality, rich-content blog articles with 2-3 sessions and 2-3 illustrations each.
Includes full schema.org markup, SEO tags, and consistent styling.
"""

import os, json

articles = [
    # 1. Macro Film Photography (VN)
    {
        "slug": "nghe-thuat-chup-anh-film-can-canh-macro",
        "lang": "vi",
        "category": "Kỹ thuật quang học",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "title": "Nghệ Thuật Chụp Macro Máy Film: Chi Tiết Tinh Thể Và Độ Mở Ống Kính",
        "desc": "Khám phá nguyên lý quang học chụp macro trên máy film 35mm, tính toán hệ số bù sáng bellows extension và cách xử lý hạt bạc ở cự ly siêu cận.",
        "hero": "../assets/blog/macro-film-dewdrop.jpg",
        "hero_caption": "Ảnh nghiên cứu: Giọt sương mai đọng trên lá thông với bokeh bọt tròn đặc trưng của nhũ tương bạc analog.",
        "img1": "../assets/blog/macro-film-dewdrop.jpg",
        "img1_caption": "Độ sâu trường ảnh mỏng tang ở tỷ lệ phóng đại 1:1, nơi từng giọt nước đóng vai trò như một thấu kính khúc xạ tự nhiên.",
        "img2": "../assets/samples/sample_leaf.png",
        "img2_caption": "Cấu trúc gân lá và viền diệp lục được tái tạo với độ chuyển màu vi điểm mềm mại trên phim dương bản.",
        "img3": "../assets/blog/rangefinder-table-sunlight.jpg",
        "img3_caption": "Bố trí thân máy cơ khí vững chãi trên mặt phẳng cố định là điều kiện tiên quyết khi bấm chụp macro ở tốc độ thấp.",
        "h2_1": "Nguyên lý suy giảm ánh sáng và hệ số bù sáng Bellows Factor",
        "p1_1": "Khi bạn di chuyển ống kính ra xa khỏi mặt phẳng phim để đạt tỷ lệ phóng đại 1:1 hoặc 1:2, khoảng cách vật lý từ thấu kính sau tới bề mặt nhũ tương tăng lên đáng kể. Theo định luật nghịch đảo bình phương khoảng cách (inverse-square law), chùm quang thông chiếu lên từng milimét vuông nhũ tương bị phân tán trên một diện tích hình nón rộng hơn, khiến độ rọi quang học suy giảm nghiêm trọng. Hiện tượng này trong nhiếp ảnh buồng tối được lượng hóa bằng hệ số suy hao ống kéo (bellows extension factor), tính theo công thức m = d / f, trong đó độ phơi sáng thực tế có thể hao hụt từ 1 đến 2 stop so với giá trị hiển thị trên vòng khẩu độ vật lý.",
        "p1_2": "Nếu người chụp chỉ tin vào máy đo sáng cầm tay hoặc thước ngắm ngoài mà không cộng bù sáng (exposure compensation), bức ảnh film macro tráng ra chắc chắn sẽ bị thiếu sáng nặng, làm mất sạch chi tiết ở các viền gân lá hay chân lông tơ của côn trùng. Trong môi trường số hóa của RfCamera, hệ thống shader tính toán tự động độ suy giảm lux của thấu kính macro ảo, giúp khung ngắm phản ánh chân thực độ sáng rọi xuống cảm biến mà không đòi hỏi người dùng phải lật bảng tra cứu bù sáng phức tạp giữa hiện trường.",
        "h2_2": "Kiểm soát mặt phẳng tiêu cự mỏng và cấu trúc bokeh bọt khí",
        "p2_1": "Ở khoảng cách lấy nét cực cận chỉ vài centimet, độ sâu trường ảnh (depth of field - DOF) co hẹp lại chỉ còn vỏn vẹn chưa đầy một milimét ngay cả khi bạn khép khẩu sâu xuống f/8 hoặc f/11. Mọi rung lắc dù là nhỏ nhất từ nhịp thở của người cầm máy hay cơn gió thoảng qua cành cây đều có thể đẩy điểm vàng lấy nét ra ngoài rìa chủ thể. Kỹ thuật then chốt ở đây không phải là xoay vòng lấy nét liên tục, mà là khóa chết thước đo trên thân ống ở mốc phóng đại mong muốn rồi nhẹ nhàng nghiêng cả thân máy tịnh tiến tới lui cho đến khi hình ảnh nét căng hiện rõ trên kính ngắm mờ.",
        "p2_2": "Vùng ngoài tiêu cự (out-of-focus background) trong chụp macro analog đem lại cảm giác thị giác tách biệt hoàn toàn so với thuật toán xóa phông giả lập của điện thoại. Nhờ cơ chế tán sắc quang học tự nhiên của các thấu kính phi cầu cổ điển kết hợp cùng lớp hạt bạc phân bố ngẫu nhiên, các đốm sáng phản chiếu từ giọt sương sẽ biến thành những bong bóng bokeh hình tròn mềm mại, không bao giờ xuất hiện viền gắt hay hiện tượng răng cưa kỹ thuật số.",
        "h2_3": "Thực hành cân bằng hạt bạc và nhũ tương độ nhạy thấp",
        "p3_1": "Để ghi lại các chi tiết siêu vi như mắt kép của chuồn chuồn hay phấn hoa li ti, việc lựa chọn cuộn phim có kích thước tinh thể bạc siêu mịn là yếu tố sống còn. Những dòng phim có ISO thấp từ 50 đến 100 như Ilford Pan F Plus hoặc Kodak Ektar 100 sở hữu cấu trúc tinh thể T-Grain xếp khít, cho phép phóng đại bản in lên khổ lớn mà không bị vỡ hạt thành từng mảng đốm cát thô ráp. Tốc độ màn trập khi chụp phim ISO thấp thường phải kéo dài từ 1/15s đến 1/2s, đòi hỏi bạn phải sử dụng dây bấm mềm cơ học hoặc ngàm kẹp cố định.",
        "p3_2": "Trong ứng dụng RfCamera, chế độ giả lập thấu kính macro tái hiện hoàn hảo cảm giác cơ học này bằng cách kết hợp cơ chế rung phản hồi haptic khi điểm nét rơi vào vùng trung tâm, đồng thời phát âm thanh tiếng chốt gương lật giảm chấn đặc trưng của các dòng máy cơ chuyên dụng thập niên 70, mang lại trải nghiệm bấm máy trang trọng và đầy tĩnh lặng."
    },

    # 2. Leica M3 Double Stroke (VN)
    {
        "slug": "leica-m3-double-stroke-huyen-thoai",
        "lang": "vi",
        "category": "Thân máy & Lịch sử",
        "readTime": "6 phút đọc",
        "date": "28 Tháng 8, 2026",
        "title": "Huyền Thoại Leica M3 Double Stroke: Cỗ Máy Đo Khoảng Cách Vĩ Đại Nhất",
        "desc": "Giải mã kiệt tác cơ khí Leica M3 ra đời năm 1954: cơ chế lên phim hai nhịp double stroke, hệ lăng kính ngắm phóng đại 0.91x và âm thanh màn trập vải êm như hơi thở.",
        "hero": "../assets/blog/leica-m3-rangefinder.jpg",
        "hero_caption": "Huyền thoại Leica M3 Double Stroke với ống kính Summicron 50mm f/2 và lớp bọc da thuộc vulcanite kinh điển.",
        "img1": "../assets/blog/leica-m3-rangefinder.jpg",
        "img1_caption": "Các núm vặn tốc độ và cơ cấu cơ học mạ crôm satin chống lóa của thân máy Leica M3 đời đầu.",
        "img2": "../assets/screenshots/01-camera.png",
        "img2_caption": "Giao diện rangefinder của RfCamera tái tạo trực quan khung ngắm 35mm với viền mờ ngoại cảnh trung thực.",
        "img3": "../assets/blog/rangefinder-table-sunlight.jpg",
        "img3_caption": "Cảm giác cầm nắm đầm tay và sự chắc chắn của vỏ đồng thau nguyên khối đúc áp lực cao.",
        "h2_1": "Cơ cấu lên phim hai nhịp và sự bền bỉ của lò xo cơ học",
        "p1_1": "Khi Ernst Leitz giới thiệu chiếc Leica M3 tại hội chợ Photokina 1954, thế giới nhiếp ảnh đã chứng kiến một cuộc cách mạng định hình toàn bộ chuẩn mực của máy ảnh 35mm cho tới tận ngày nay. Ở các phiên bản đầu tiên mang số serial dưới 919.251, cần lên phim đòi hỏi người chụp phải gạt hai nhịp ngắn liên tiếp (Double Stroke - DS) thay vì một nhịp dài. Cú gạt thứ nhất có nhiệm vụ cuốn chính xác một khung hình phim 24x36mm trên trục gai, trong khi cú gạt thứ hai nạp căng lò xo kéo màn trập vải di chuyển theo chiều ngang. Thiết kế này phân bổ đều tải trọng cơ học, ngăn ngừa triệt để nguy cơ làm rách mép lỗ phim celluloid mỏng manh trong mùa đông buốt giá.",
        "p1_2": "Âm thanh khi lên phim hai nhịp của M3 có một độ mượt mà khó tả, êm ái như tiếng xoay của một chiếc đồng hồ Thụy Sĩ cao cấp. Không có bánh răng nhựa, không có mạch điện bán dẫn, toàn bộ hệ thống truyền động bên trong thân máy được lắp ráp từ đồng thau cắt gọt tinh xảo và thép tôi cứng, cho phép thiết bị hoạt động bền bỉ qua hàng nửa thế kỷ mà không cần bất kỳ viên pin nào hỗ trợ.",
        "h2_2": "Khung ngắm phóng đại 0.91x và ô trùng chập huyền thoại",
        "p2_1": "Điểm sáng chói lọi nhất của Leica M3 chính là cụm lăng kính trắc cự (rangefinder optical assembly) có tỷ lệ phóng đại lên tới 0.91x - mức phóng đại lớn nhất từng được chế tạo trong toàn bộ dòng Leica M. Khi nhìn bằng mắt phải qua kính ngắm của M3, kích thước của chủ thể trong khung gần như tương đương 1:1 với mắt trái đang mở to nhìn ra ngoài trời. Điều này giúp nhiếp ảnh gia đường phố giữ trọn nhận thức không gian hai mắt, quan sát được dòng người chuẩn bị bước vào khung hình trước cả khi họ chạm tới đường viền tiêu cự.",
        "p2_2": "Cơ chế trùng chập (coincidence focusing) của M3 sử dụng một đốm sáng chữ nhật sắc nét ở trung tâm. Người chụp chỉ việc xoay nhẹ vòng lấy nét trên ống kính Summicron cho đến khi hai hình ảnh lệch pha chập khít vào nhau thành một khối duy nhất. Độ chính xác của thước đo cự ly trên M3 lớn đến mức bạn hoàn toàn có thể tự tin mở khẩu tối đa f/1.4 hay f/2 trong điều kiện ánh sáng nhập nhoạng mà không bao giờ lo lệch nét vào đuôi mắt hay chóp mũi chủ thể.",
        "h2_3": "Tái hiện linh hồn M3 trên trải nghiệm số RfCamera",
        "p3_1": "Lấy cảm hứng từ triết lý cơ khí thuần khiết của Leica M3, đội ngũ kỹ thuật RfCamera đã dành hàng trăm giờ phân tích quang phổ âm thanh thực tế của màn trập vải cao su. Khi bạn bấm chụp trên ứng dụng, âm thanh cơ học vang lên không phải là một file ghi âm MP3 nén đơn giản, mà là chuỗi âm sắc được tổng hợp thời gian thực mô phỏng chính xác ba giai đoạn: tiếng nhả chốt hãm, tiếng rèm vải quét qua cửa sổ phơi sáng và tiếng lò xo giảm chấn hãm lại ở cuối hành trình.",
        "p3_2": "Đi cùng với đó là bố cục rangefinder đặc hữu trên màn hình cảm ứng: toàn bộ cảnh vật bên ngoài khung viền 35mm được làm mờ nhẹ và giảm độ sáng 30%, tái hiện đúng cảm giác bạn đang ghé mắt vào một ô kính ngắm quang học đắt giá, nơi mỗi nút bấm chụp là một sự cam kết tuyệt đối với khoảnh khắc thoáng qua."
    },

    # 3. Kodak Tri-X 400 (VN)
    {
        "slug": "kodak-tri-x-400-do-tuong-phan-duong-pho",
        "lang": "vi",
        "category": "Cuộn phim & Màu sắc",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "title": "Kodak Tri-X 400: Hạt Bạc Thô Mộc Định Hình Nhiếp Ảnh Phóng Sự",
        "desc": "Tìm hiểu cuộn phim đen trắng huyền thoại Kodak Tri-X 400: độ tương phản sâu thẳm, cấu trúc hạt grain sắc bén và dung sai đẩy sáng push process tới ISO 1600.",
        "hero": "../assets/blog/street-monochrome-tri-x.jpg",
        "hero_caption": "Góc phố đêm Tokyo dưới mưa chụp trên Kodak Tri-X 400 với độ tương phản gắt gao và bóng đổ đen kịt.",
        "img1": "../assets/blog/street-monochrome-tri-x.jpg",
        "img1_caption": "Bề mặt nhựa đường ướt phản chiếu ánh đèn neon qua lăng kính đơn sắc với hạt grain bạc rõ rệt.",
        "img2": "../assets/samples/sample_street.jpg",
        "img2_caption": "Khoảnh khắc đời thường giàu tính tự sự được bóc tách khỏi sự chi phối của màu sắc.",
        "img3": "../assets/blog/leica-m3-rangefinder.jpg",
        "img3_caption": "Sự kết hợp giữa thân máy cơ khí nhỏ gọn và cuộn phim Tri-X là bộ công cụ bất hủ của các phóng viên Magnum.",
        "h2_1": "Bản sắc tương phản cao và độ sắc nét quang học Acutance",
        "p1_1": "Ra mắt lần đầu ở định dạng cuộn 35mm vào năm 1954, Kodak Tri-X 400 (mã hiệu TX) nhanh chóng trở thành thước đo tiêu chuẩn cho toàn bộ giới nhiếp ảnh báo chí, tài liệu và đường phố thế kỷ 20. Khác với dòng phim Ilford HP5 có xu hướng giữ sắc xám trung tính mềm mại, Tri-X sở hữu đường đặc tuyến tương phản hình chữ S dốc đứng. Các mảng đen của bóng râm đổ xuống sâu thẳm và dứt khoát, trong khi vùng sáng highlight giữ được độ rực rỡ mà không hề bị đục mờ.",
        "p1_2": "Bí mật làm nên sức hút thị giác trường tồn của Tri-X nằm ở khái niệm acutance - độ sắc nét viền cạnh quang học. Cấu trúc hạt bạc của Tri-X không mịn màng giả tạo mà kết tinh thành những khối tinh thể góc cạnh, tạo cho các đường nét ranh giới giữa sáng và tối một độ gai góc sắc lẹm, khiến người xem có cảm giác bức ảnh có độ sâu khối nổi khối ba chiều ngay trên mặt phẳng giấy rọi 2D.",
        "h2_2": "Sức mạnh đẩy sáng Push Processing lên ISO 1600 và 3200",
        "p2_1": "Trong những ngõ hẻm tối tăm của các đô thị hay bên trong những câu lạc bộ nhạc Jazz mờ ảo khói thuốc, mức nhạy sáng ISO 400 nguyên bản thường không đủ để giữ tốc độ chụp an toàn trên 1/60s. Đây chính là lúc kỹ thuật đẩy sáng (push processing) phát huy quyền năng tối thượng của Tri-X. Bằng cách gạt thước đo sáng trên máy ảnh lên ISO 800, 1600 hoặc thậm chí 3200 khi chụp, rồi kéo dài thời gian ngâm phim trong dung dịch thuốc tráng Kodak D-76 hoặc Rodinal trong phòng tối, các nhiếp ảnh gia có thể chụp ảnh trong bóng đêm gần như hoàn toàn.",
        "p2_2": "Khi được push lên ISO 1600, hạt grain của Tri-X bùng nổ dữ dội, các sắc độ xám trung gian nhường chỗ cho sự đối đầu gay gắt giữa đen tuyền và trắng tinh khiết. Chất ảnh gai góc này đã trực tiếp khai sinh ra phong cách nhiếp ảnh khiêu khích 'Are, Bure, Boke' (Thô ráp, Mờ nhòe, Mất nét) của các nghệ sĩ trường phái Provoke Nhật Bản như Daido Moriyama.",
        "h2_3": "Tái tạo độ sâu đơn sắc trong hệ sinh thái RfCamera",
        "p3_1": "Để mang đúng tinh thần mộc mạc ấy vào chiếc điện thoại của bạn, dòng máy giả lập GR-D trong RfCamera áp dụng một ma trận chuyển đổi đơn sắc tùy biến. Thay vì chỉ đơn thuần triệt tiêu độ bão hòa màu (desaturate) như các app thông thường, thuật toán của RfCamera tính toán lại tỷ lệ nhạy quang tương đương kính lọc vàng-cam, chủ động nâng độ sáng của màu da và dìm độ sáng của mảng trời xanh, tạo nên một bức tranh đen trắng giàu cảm xúc.",
        "p3_2": "Lớp hạt grain được phủ lên ảnh là hạt nhiễu vi điểm tạo ra từ thuật toán giải phương trình vi phân ngẫu nhiên trên shader GPU, đảm bảo mỗi khung hình bạn bấm chụp đều có một cấu trúc hạt độc nhất vô nhị, phản ánh trung thực bản chất vật lý của tinh thể bạc hữu cơ."
    },

    # 4. Fujicolor C200 (VN)
    {
        "slug": "fujicolor-c200-sac-mau-nhat-ban-trong-treo",
        "lang": "vi",
        "category": "Cuộn phim & Màu sắc",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "title": "Fujicolor C200: Sắc Xanh Lơ Trong Trẻo Của Phố Phường Mùa Hè",
        "desc": "Khám phá bảng màu đặc trưng của cuộn phim Fujicolor C200: sắc xanh lục lá cây dịu mát, tông xanh lơ cyan ở bóng râm và cảm xúc hoài niệm mùa hè Nhật Bản.",
        "hero": "../assets/blog/fujicolor-summer-greens.jpg",
        "hero_caption": "Khu phố dân cư thanh bình dưới nắng hè tráng trên phim Fujicolor C200 với sắc xanh lá cây tươi tắn dịu mắt.",
        "img1": "../assets/blog/fujicolor-summer-greens.jpg",
        "img1_caption": "Bầu trời xanh ngọc bích hòa quyện cùng tán lá rợp bóng, đặc trưng thị giác của dòng nhũ tương Fuji 35mm.",
        "img2": "../assets/samples/sample_palm.jpg",
        "img2_caption": "Tán dừa nhiệt đới dưới nắng gắt vẫn giữ được sắc độ xanh mát mẻ, không bị ngả vàng gay gắt.",
        "img3": "../assets/blog/rangefinder-table-sunlight.jpg",
        "img3_caption": "Cuộn phim C200 là lựa chọn bỏ túi hàng ngày của hàng triệu bạn trẻ yêu thích phong cách ảnh đường phố châu Á.",
        "h2_1": "Bản sắc nhũ tương Fujifilm và sắc xanh lục lục bảo độc tôn",
        "p1_1": "Nếu như đối thủ truyền kiếp Kodak từ bờ tây nước Mỹ nổi tiếng với tông màu vàng hổ phách nồng ấm như ánh nắng hoàng hôn California, thì Fujifilm lại chọn một triết lý quang phổ hoàn toàn khác biệt. Dòng phim âm bản phổ thông Fujicolor C200 được thiết kế để ưu tiên phản ánh sắc độ xanh lục (green) và xanh lơ (cyan) một cách dịu mát và thanh thoát nhất. Dưới ánh nắng ban ngày 5500K, các tán cây cối, bờ tường rêu phong hay biển hiệu rợp bóng ven đường hiện lên với một độ tươi tắn đặc biệt mà không bao giờ bị chói gắt.",
        "p1_2": "Cơ chế này bắt nguồn từ cấu trúc lớp nhũ tương thứ tư (4th Color Layer) được các kỹ sư hóa dầu Nhật Bản phát minh nhằm hạn chế hiện tượng ánh sáng huỳnh quang xanh lá cây trong nhà làm hỏng màu phim. Nhờ đó, phim Fuji có khả năng xử lý các nguồn sáng phức hợp cực kỳ thông minh, biến những mảng màu da người trở nên sáng hồng hào tự nhiên trên nền hậu cảnh xanh mướt mát mắt.",
        "h2_2": "Tông màu Cyan ở vùng bóng râm và cảm thức hoài niệm",
        "p2_1": "Một đặc điểm nhận dạng không thể nhầm lẫn của Fujicolor C200 chính là sự dịch chuyển sắc độ ở các vùng bóng tối trung bình (shadow roll-off). Khi đi dạo dưới những con phố rợp bóng cây hay hành lang khu tập thể cũ, các mảng tối dưới gầm cầu thang hay kẽ lá không ngả sang đen đặc mà từ từ hòa vào một dải màu xanh ngọc lam (cool cyan) bảng lảng. Đây chính là yếu tố tạo nên phong cách nhiếp ảnh 'Japanese Clean Aesthetic' thường thấy trong các bộ phim điện ảnh của đạo diễn Kore-eda Hirokazu.",
        "p2_2": "Độ bão hòa màu của C200 nằm ở mức cân bằng hoàn hảo: không quá rực rỡ như dòng phim trượt Velvia, nhưng cũng không quá phẳng lặng như phim chân dung chuyên nghiệp. Nó ghi lại nhịp sống thường nhật với một thái độ điềm đạm, biến những đồ vật bình dị như chiếc xe đạp tựa chân tường hay cốc trà đá ven đường thành những lát cắt ký ức đầy thơ mộng.",
        "h2_3": "Trải nghiệm dòng phim màu Nhật Bản trên RfCamera",
        "p3_1": "Trong bộ sưu tập máy ảnh của RfCamera, camera giả lập phong cách du lịch châu Á áp dụng chính xác ma trận chuyển đổi màu sắc của nhũ tương C200. Các kênh màu Green và Cyan được tinh chỉnh hệ số hấp thụ để đẩy nhẹ sắc xanh bạc hà ở các vùng trung tông, đồng thời giữ cho tông màu da mặt luôn giữ được vẻ trắng trẻo, mịn màng tự nhiên.",
        "p3_2": "Điểm đặc biệt là thuật toán của RfCamera tái tạo được cả hiện tượng tán xạ ánh sáng mềm quanh các đốm nắng chiếu qua kẽ lá, giúp bức ảnh chụp bằng camera điện thoại của bạn lập tức rũ bỏ vẻ sắc nét kỹ thuật số nhân tạo để khoác lên mình màu áo mộc mạc, trong lành của một cuộn phim mùa hè đích thực."
    },

    # 5. Double Exposure (VN)
    {
        "slug": "ky-thuat-chup-phoi-sang-kep-double-exposure",
        "lang": "vi",
        "category": "Kỹ thuật sáng tạo",
        "readTime": "6 phút đọc",
        "date": "28 Tháng 8, 2026",
        "title": "Làm Chủ Kỹ Thuật Phơi Sáng Kép: Ghép Nối Không Gian Trên Phim 35mm",
        "desc": "Hướng dẫn làm chủ kỹ thuật phơi sáng kép (Double Exposure) trên máy ảnh cơ: nguyên lý cộng dồn quang lượng, quy tắc bóng tối và cách lồng ghép chân dung siêu thực.",
        "hero": "../assets/blog/double-exposure-portrait.jpg",
        "hero_caption": "Tác phẩm phơi sáng kép nghệ thuật kết hợp góc nghiêng chân dung thiếu nữ với rặng thông và sương mù vùng cao.",
        "img1": "../assets/blog/double-exposure-portrait.jpg",
        "img1_caption": "Bóng tối của hình thể đóng vai trò như một khuôn cửa sổ mở ra khung cảnh thiên nhiên kỳ ảo bên trong.",
        "img2": "../assets/samples/sample_beach.jpg",
        "img2_caption": "Mặt biển lấp lánh sóng nước là nguồn họa tiết lý tưởng để lồng ghép vào khung hình phơi sáng thứ hai.",
        "img3": "../assets/screenshots/03-color-config.png",
        "img3_caption": "Cấu hình hòa trộn thời gian thực trên RfCamera cho phép người chụp xem trước hiệu ứng trước khi chốt bấm máy.",
        "h2_1": "Nguyên lý vật lý cộng dồn mật độ quang học trên nhũ tương",
        "p1_1": "Phơi sáng kép (Double Exposure) là kỹ thuật cho phép người chụp cho cùng một khung hình phim tiếp xúc với ánh sáng hai hoặc nhiều lần liên tiếp trước khi cuốn phim sang khung tiếp theo. Về mặt hóa học lượng tử, mỗi photon ánh sáng đi qua ống kính sẽ kích hoạt một số lượng tinh thể bạc halogenua trên bề mặt phim. Khi bạn bấm máy lần thứ hai, lượng photon mới sẽ tiếp tục kích hoạt thêm các tinh thể bạc còn sót lại trên cùng diện tích nhũ tương ấy. Mật độ quang học cuối cùng sau khi tráng là tổng hòa tích lũy của cả hai lần bấm máy.",
        "p1_2": "Quy tắc cốt lõi cần khắc cốt ghi tâm: Ánh sáng chỉ có thể cộng thêm vào, không bao giờ có thể trừ đi. Một khi một vùng trên khung hình đã bị cháy sáng trắng tinh ở lần bấm thứ nhất, toàn bộ tinh thể bạc ở khu vực đó đã phản ứng hết mức tối đa; lần bấm thứ hai sẽ hoàn toàn không để lại bất kỳ dấu vết nào lên vùng sáng đó nữa.",
        "h2_2": "Quy tắc bóng tối Silhouette và kỹ thuật đo sáng -1 EV",
        "p2_1": "Chính vì nguyên lý cộng sáng một chiều, kỹ thuật phơi sáng kép đẹp mắt luôn bắt đầu bằng việc tạo ra một hình bóng đen dứt khoát (silhouette) ở lần chụp đầu tiên. Khi chụp chân dung ngược sáng mạnh mẽ lúc hoàng hôn hoặc trước một bờ tường trắng, khuôn mặt và thân hình của người mẫu sẽ rơi vào vùng tối sâu thẳm. Vùng bóng đen này chính là 'mảnh đất màu mỡ' chứa toàn bộ các tinh thể bạc nguyên vẹn, sẵn sàng đón nhận toàn bộ chi tiết, họa tiết và màu sắc của lần bấm chụp thứ hai.",
        "p2_2": "Về mặt đo sáng, nếu cả hai bức ảnh đều được chụp ở mức phơi sáng tiêu chuẩn, tổng lượng sáng cộng dồn sẽ khiến bức ảnh bị dư sáng 1 stop (+1 EV). Do đó, người chụp chuyên nghiệp luôn chủ động hạ bánh xe bù sáng của máy xuống -1 EV ở cả hai lần bấm chụp (hoặc khép khẩu thêm 1 stop), giúp cân bằng chính xác tổng mật độ quang học của bức ảnh hoàn chỉnh.",
        "h2_3": "Sáng tạo siêu thực không giới hạn cùng RfCamera",
        "p3_1": "Trên các dòng máy film cơ học cổ điển, việc chụp chồng hình đòi hỏi thao tác giữ chặt nút mở khóa trục tua phim (rewind release pin) dưới đáy máy đồng thời gạt cần lên phim một cách cực kỳ khéo léo để không làm xê dịch vị trí bánh răng. Một sai sót nhỏ cũng khiến khung hình bị lệch trục hoặc chồng đè méo mó.",
        "p3_2": "Với RfCamera, tính năng chồng hình được hiện đại hóa tinh tế: ứng dụng lưu giữ khung hình thứ nhất ở bộ nhớ đệm GPU và hiển thị dưới dạng một lớp bóng mờ (ghost layer) trong suốt trên khung ngắm trực tiếp. Bạn có thể thong thả căn chỉnh đường nét của nhánh cây, tòa nhà hay mặt nước sao cho khớp hoàn hảo với đường viền cơ thể người mẫu, biến mỗi cú bấm màn trập thành một tác phẩm nghệ thuật độc bản đầy mê hoặc."
    },

    # 6. Anamorphic Lens (VN)
    {
        "slug": "ong-kinh-anamorphic-vet-sang-dien-anh",
        "lang": "vi",
        "category": "Kỹ thuật quang học",
        "readTime": "6 phút đọc",
        "date": "28 Tháng 8, 2026",
        "title": "Ống Kính Anamorphic: Vệt Lóa Xanh Ngang Và Tỷ Lệ Màn Bạc 2.39:1",
        "desc": "Khám phá cấu trúc quang học thấu kính trụ anamorphic: cách nén hình ảnh quang học, vệt flare xanh tia ngang và cảm xúc điện ảnh hoài niệm trên phim 35mm.",
        "hero": "../assets/blog/anamorphic-night-flares.jpg",
        "hero_caption": "Cảnh phố đêm đậm chất điện ảnh với vệt lóa ngang màu xanh lơ đặc trưng của ống kính anamorphic 2.39:1.",
        "img1": "../assets/blog/anamorphic-night-flares.jpg",
        "img1_caption": "Vệt flare kéo dài theo trục hoành biến những bóng đèn đường đơn điệu thành một khung cảnh màn bạc sống động.",
        "img2": "../assets/samples/sample_traindoor.jpg",
        "img2_caption": "Ánh sáng xuyên qua khung cửa toa tàu tạo nên những vệt quang sai độc đáo khi được nén qua thấu kính trụ.",
        "img3": "../assets/screenshots/04-focal-tray.png",
        "img3_caption": "Khay chuyển đổi tiêu cự và tỷ lệ khung hình trên RfCamera giúp mở rộng góc nhìn chuẩn tỷ lệ rạp chiếu phim.",
        "h2_1": "Cơ chế nén hình quang học của thấu kính trụ Cylindrical Glass",
        "p1_1": "Trong lịch sử điện ảnh Hollywood thập niên 1950, để đối phó với sự bùng nổ của màn hình vô tuyến gia đình, các hãng phim đã phát minh ra hệ thống thấu kính anamorphic để trình chiếu định dạng màn hình siêu rộng CinemaScope mà không cần phải thay đổi khổ phim 35mm tiêu chuẩn. Thay vì sử dụng toàn bộ thấu kính cầu (spherical elements) truyền thống, ống kính anamorphic tích hợp các thấu kính trụ đặc biệt có khả năng bóp nghẹt hình ảnh theo chiều ngang theo tỷ lệ 2x hoặc 1.33x, trong khi chiều dọc vẫn giữ nguyên tỷ lệ 1:1.",
        "p1_2": "Khi cuộn phim tráng xong được đưa vào máy chiếu trong rạp, một thấu kính giải nén (de-squeeze) tương ứng sẽ kéo giãn hình ảnh trở lại chiều rộng nguyên bản, tạo ra một tỷ lệ khung hình siêu rộng 2.39:1 đầy choáng ngợp. Kỹ thuật này cho phép khai thác trọn vẹn từng milimét vuông diện tích hữu ích của tấm phim âm bản, đem lại độ chi tiết vượt trội so với việc cắt cúp (crop) viền đen trên dưới đơn thuần.",
        "h2_2": "Vệt quang sai ngang Blue Streak và hiện tượng Oval Bokeh",
        "p2_1": "Dấu ấn thẩm mỹ quyến rũ nhất của quang học anamorphic chính là những vệt lóa sáng kéo dài theo chiều ngang (horizontal streak flares). Khi một nguồn sáng điểm cường độ cao - như đèn pha ô tô, bóng đèn neon hay ngọn nến trong đêm - chiếu trực diện vào mặt trước ống kính, ánh sáng bị phản xạ nội tại giữa các bề mặt thấu kính cong hình trụ và lớp tráng phủ chống phản quang (lens coating). Thay vì tạo ra các vòng tròn lóa đồng tâm như ống kính thông thường, ánh sáng bị kéo dẹt thành một dải tia sáng màu xanh lơ (horizontal blue streak) vắt ngang toàn bộ khung hình.",
        "p2_2": "Đi kèm với đó là hình dạng của các đốm sáng ngoài tiêu cự (bokeh). Do hiện tượng nén quang học 2:1, những đốm sáng hình tròn thông thường sẽ biến đổi thành những quả trứng hình bầu dục dục đứng (oval bokeh) vô cùng duyên dáng. Vùng chuyển nét giữa chủ thể và phông nền phía sau có một độ cuộn hút kỳ ảo, kéo người xem chìm sâu vào trung tâm hành động của nhân vật chính.",
        "h2_3": "Mô phỏng quang sai Anamorphic bằng Shader GPU thời gian thực",
        "p3_1": "Để sở hữu một ống kính anamorphic cổ điển chính hãng ngày nay, các nhà làm phim phải chi trả từ hàng nghìn đến hàng chục nghìn đô la, chưa kể trọng lượng cồng kềnh đòi hỏi hệ thống giá đỡ chuyên dụng. Trong RfCamera, toàn bộ các quy luật quang học phức tạp này được lập trình lại thành các thuật toán xử lý phân mảnh (fragment shaders) chạy trực tiếp trên chip đồ họa của điện thoại.",
        "p3_2": "Shader của RfCamera chủ động phân tích các vùng sáng có cường độ lumen vượt ngưỡng trần, áp dụng ma trận tích chập một chiều theo phương ngang để tạo vệt lóa xanh điện ảnh, đồng thời tái tạo độ méo rìa thùng phuy và lớp quang sai sắc viền tím (chromatic aberration) chân thực, mang lại trải nghiệm bấm máy chuẩn rạp chiếu phim Hollywood ngay trong tầm tay bạn."
    },

    # 7. Hasselblad 500C/M (VN)
    {
        "slug": "hasselblad-500cm-kho-trung-goc-nhin-ngang-hong",
        "lang": "vi",
        "category": "Thân máy & Lịch sử",
        "readTime": "6 phút đọc",
        "date": "28 Tháng 8, 2026",
        "title": "Nghi Thức Ngắm Ngang Hông: Hasselblad 500C/M Và Định Dạng Vuông 6x6",
        "desc": "Trải nghiệm nghi thức chụp ảnh khổ trung với Hasselblad 500C/M: khung ngắm waist-level đảo ngược trái phải, định dạng vuông 6x6 và triết lý làm chậm thời gian.",
        "hero": "../assets/blog/hasselblad-waist-level.jpg",
        "hero_caption": "Nhìn trực diện vào kính ngắm ngang hông của Hasselblad 500C/M với khung cảnh hồ núi hiện rõ trên mặt kính mờ.",
        "img1": "../assets/blog/hasselblad-waist-level.jpg",
        "img1_caption": "Khung ngắm xếp nắp che sáng bằng da và kính lúp tích hợp để kiểm tra độ sắc nét ở cự ly mắt gần.",
        "img2": "../assets/blog/hasselblad-waist-level-alt.jpg",
        "img2_caption": "Mặt kính mờ ground-glass với các đường kẻ lưới chữ thập hỗ trợ căn chỉnh đường chân trời chuẩn xác.",
        "img3": "../assets/samples/sample_field.jpg",
        "img3_caption": "Bố cục vuông 1:1 đem lại sự tĩnh lặng và cân bằng tuyệt đối cho các tác phẩm phong cảnh rộng lớn.",
        "h2_1": "Nghi thức ngắm ngang hông và sự đảo ngược thị giác",
        "p1_1": "Khác với thao tác ghé sát mắt vào kính ngắm của máy ảnh 35mm, chụp máy ảnh khổ trung (Medium Format) như Hasselblad 500C/M là một nghi thức mang tính chiêm nghiệm sâu sắc. Nhiếp ảnh gia đeo dây da quanh cổ, hạ thân máy hình khối vuông vức xuống ngang thắt lưng và cúi đầu nhìn xuống mặt kính mờ (ground-glass screen). Do không sử dụng lăng kính năm mặt (pentaprism) đảo ảnh, hình ảnh phản chiếu trên kính mờ sẽ bị đảo ngược hoàn toàn theo chiều ngang: người đi từ trái sang phải ngoài đời thực sẽ di chuyển từ phải sang trái trên mặt kính.",
        "p1_2": "Sự đảo nghịch thị giác này thoạt đầu khiến người mới cảm thấy bối rối khi lia máy, nhưng chính nó lại giúp bộ não tách rời chủ thể khỏi ý nghĩa thực tại để nhìn nhận khung hình thuần túy như một bố cục trừu tượng của hình khối, ánh sáng và đường nét. Bạn không còn 'nhìn' một con người hay một cái cây, mà đang ngắm nhìn một bức tranh sơn dầu sống động đang chuyển động trên mặt phẳng kính.",
        "h2_2": "Quyền năng của định dạng vuông 6x6 và diện tích nhũ tương khổng lồ",
        "p2_1": "Một khung phim khổ trung 6x6cm trên cuộn phim 120 sở hữu diện tích bề mặt lớn gấp gần 4 lần so với một khung phim 35mm tiêu chuẩn (24x36mm). Lượng thông tin quang học, độ chuyển tiếp sắc độ giữa các vùng xám và dung sai chi tiết trong bóng tối của phim 120 vượt trội hoàn toàn so với khổ nhỏ. Ngay cả khi bạn phóng to bức ảnh rọi lên khổ tường 2 mét, từng nếp nhăn trên trán nhân vật hay từng vân đá trên vách núi vẫn giữ được độ sắc nét kinh ngạc.",
        "p2_2": "Hơn thế nữa, tỷ lệ khung hình vuông 1:1 giải phóng người chụp khỏi sự đắn đo giữa việc xoay máy ngang hay dọc. Bố cục vuông mang một nội lực tĩnh tại, tạo ra sự cân bằng hoàn hảo giữa bốn cạnh và dồn toàn bộ sự chú ý của thị giác vào trọng tâm bức ảnh. Nó đòi hỏi một tư duy sắp đặt hình học chặt chẽ và kỷ luật cao độ.",
        "h2_3": "Tiếng màn trập phụ và trải nghiệm máy khổ lớn trên RfCamera",
        "p3_1": "Bấm chụp một chiếc Hasselblad là một sự kiện âm thanh đầy uy lực. Khi ngón tay ấn nút nhả màn trập, một chuỗi phản ứng dây chuyền cơ học diễn ra trong chớp mắt: cửa sổ kính ngắm phụ đóng lại, gương lật bật văng lên, lá khẩu trên ống kính khép lại mốc định sẵn và rèm thép phụ mở ra với một tiếng 'CLACK-BOOM' vang dội đầy dứt khoát.",
        "p3_2": "Trong ứng dụng RfCamera, camera S67 tái hiện trọn vẹn ma lực của định dạng này: khung hình vuông 1:1 với kính ngắm mờ ground-glass mô phỏng độ sáng hơi tối dần ở bốn góc (vignetting), kết hợp cùng âm thanh cơ khí trầm ấm uy nghiêm, giúp bạn tìm lại sự lắng đọng và nghiêm cẩn cần thiết trong từng lần bấm máy giữa nhịp sống số vội vã."
    },

    # 8. Cyanotype (VN)
    {
        "slug": "ky-thuat-in-anh-cyanotype-nang-mat-troi",
        "lang": "vi",
        "category": "Kỹ thuật sáng tạo",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "title": "Bản In Xanh Cyanotype: Kỹ Thuật Tráng Rọi Mặt Trời Từ Năm 1842",
        "desc": "Khám phá quy trình in ấn cổ điển Cyanotype ra đời từ năm 1842: phản ứng hóa học của muối sắt dưới tia cực tím, sắc xanh phổ Prussian Blue và chất cảm thủ công độc bản.",
        "hero": "../assets/blog/cyanotype-botanical-print.jpg",
        "hero_caption": "Bản in cyanotype thủ công với hình bóng dương xỉ trắng tinh khôi trên nền xanh phổ Prussian Blue sâu thẳm.",
        "img1": "../assets/blog/cyanotype-botanical-print.jpg",
        "img1_caption": "Kết cấu giấy màu nước thô ráp kết hợp cùng đường viền cọ quét nham nhở tạo nên tính độc bản không thể sao chép.",
        "img2": "../assets/blog/macro-film-dewdrop.jpg",
        "img2_caption": "Những mẫu vật thực vật có độ chi tiết cao là đề tài kinh điển của nữ nhiếp ảnh gia tiên phong Anna Atkins.",
        "img3": "../assets/samples/sample_leaf.png",
        "img3_caption": "Ánh sáng tự nhiên và dung dịch hóa học thẩm thấu vào từng thớ sợi bông của giấy mỹ thuật.",
        "h2_1": "Hóa học muối sắt và năng lượng của tia tử ngoại UV",
        "p1_1": "Được phát minh bởi nhà thiên văn học và khoa học người Anh Sir John Herschel vào năm 1842, Cyanotype là một trong những quy trình in ảnh phi bạc (non-silver alternative process) cổ xưa và bền vững nhất trong lịch sử nhân loại. Thay vì sử dụng muối bạc halogenua đắt đỏ, quy trình này dựa trên phản ứng nhạy sáng của hai hợp chất muối sắt: Potassium Ferricyanide (muối sắt III) và Ferric Ammonium Citrate (sắt amoni xitrat). Khi hòa trộn hai dung dịch này theo tỷ lệ 1:1 trong phòng tối, một dung dịch nhạy sáng màu xanh ngọc bích nhạt sẽ được hình thành.",
        "p1_2": "Dung dịch sau đó được quét đều lên bề mặt giấy mỹ thuật hoặc vải sợi tự nhiên và để khô hoàn toàn trong bóng râm. Khi đem tấm giấy ra phơi dưới ánh nắng mặt trời trực tiếp, bức xạ tia cực tím (UV rays) sẽ kích hoạt phản ứng khử quang hóa, biến đổi ion sắt III thành sắt II, tạo thành hợp chất không tan trong nước mang tên Ferric Ferrocyanide - hay còn được biết đến rộng rãi với tên gọi sắc tố Xanh Phổ (Prussian Blue).",
        "h2_2": "Quy trình tráng nước tinh khiết và vẻ đẹp thủ công độc bản",
        "p2_1": "Điều kỳ diệu của quy trình Cyanotype là nó không đòi hỏi bất kỳ loại hóa chất định hình (fixer) độc hại nào như tráng phim thông thường. Sau khi phơi sáng từ 5 đến 15 phút tùy cường độ nắng, tấm giấy chỉ cần được ngâm rửa trực tiếp dưới vòi nước lạnh chảy nhẹ. Nước sạch sẽ cuốn trôi toàn bộ phần muối sắt chưa bị ánh nắng chiếu tới, để lộ ra những mảng trắng muốt của thớ giấy, trong khi vùng nhận sáng sẽ sẫm lại thành một màu xanh lam đậm đà, sang trọng và vĩnh cửu với thời gian.",
        "p2_2": "Nữ thực vật học Anna Atkins đã ứng dụng kỹ thuật này vào thập niên 1850 để xuất bản cuốn sách minh họa bằng hình ảnh đầu tiên trên thế giới mang tên 'British Algae: Cyanotype Impressions'. Từng vệt chổi quét thủ công loang lổ ở mép giấy, độ thấm hút của sợi bông và sự biến thiên của góc chiếu mặt trời khiến mỗi bản in cyanotype trở thành một tác phẩm nghệ thuật độc bản duy nhất, không có bức thứ hai giống hệt trên đời.",
        "h2_3": "Mang sắc xanh Prussian cổ kính vào RfCamera",
        "p3_1": "Nhằm tôn vinh di sản hóa học vĩ đại của thế kỷ 19, RfCamera cung cấp một bộ lọc quang phổ Cyanotype độc quyền trong bảng cấu hình màu nâng cao. Thuật toán phân tích sắc độ của bức ảnh, chuyển toàn bộ phổ màu trung tính sang dải bước sóng xanh lam 450-485nm của phẩm màu Prussian Blue, đồng thời ép toàn bộ dải sáng highlight về sắc trắng ngà của giấy thủ công.",
        "p3_2": "Đặc biệt, hệ thống shader còn giả lập cả kết cấu bề mặt thô ráp của giấy màu nước ép lạnh (cold-pressed watercolor paper) và độ chuyển sắc tiệm tiến mờ ảo ở các góc viền, giúp bạn dễ dàng tạo ra những bức ảnh thực vật, chân dung hay kiến trúc mang đậm dấu ấn mỹ thuật cổ điển ngay từ khung ngắm điện thoại."
    },

    # 9. Kodak Ektar 100 (VN)
    {
        "slug": "kodak-ektar-100-phong-canh-bien-da",
        "lang": "vi",
        "category": "Cuộn phim & Màu sắc",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "title": "Kodak Ektar 100: Độ Mịn Hạt Vi Điểm Cho Ảnh Phong Cảnh Rực Rỡ",
        "desc": "Phân tích cuộn phim màu âm bản mịn hạt nhất thế giới Kodak Ektar 100: công nghệ tinh thể T-Grain, độ bão hòa màu sống động và sức mạnh chinh phục phong cảnh thiên nhiên.",
        "hero": "../assets/blog/kodak-ektar-cliffs.jpg",
        "hero_caption": "Vách đá đỏ rực rỡ vươn ra biển xanh ngọc bích lúc hoàng hôn chụp trên phim Kodak Ektar 100.",
        "img1": "../assets/blog/kodak-ektar-cliffs.jpg",
        "img1_caption": "Độ bão hòa màu sắc sống động và độ tương phản quang học sắc sảo làm nổi bật sự kỳ vĩ của thiên nhiên.",
        "img2": "../assets/samples/sample_beach.jpg",
        "img2_caption": "Từng lớp sóng biển và bọt trắng xóa được bóc tách chi tiết mà không hề bị bết dính hay vỡ hạt.",
        "img3": "../assets/samples/sample_palm.jpg",
        "img3_caption": "Sắc xanh lục đậm đà và bầu trời nhiệt đới trong vắt là thế mạnh vượt trội của dòng nhũ tương Ektar.",
        "h2_1": "Công nghệ hạt tinh thể siêu mịn T-Grain tiên tiến",
        "p1_1": "Được Kodak tái sinh vào năm 2008 nhằm chứng minh phim analog vẫn có thể thách thức sự trỗi dậy của cảm biến kỹ thuật số, Kodak Professional Ektar 100 được công nhận là cuộn phim màu âm bản có hạt mịn nhất thế giới (World's Finest Grain). Để đạt được chỉ số độ mịn RMS 25 ở mức kinh ngạc này, Kodak đã ứng dụng công nghệ tinh thể bạc dạng bảng dẹt T-Grain (Tabular Grain) thế hệ mới nhất vốn từng được phát triển cho phim điện ảnh Hollywood.",
        "p1_2": "Các tinh thể bạc truyền thống có hình dạng khối cầu ngẫu nhiên, khi xếp chồng lên nhau sẽ tạo ra các khe hở làm tán xạ tia sáng. Ngược lại, các tinh thể T-Grain của Ektar được dát phẳng như những chiếc đĩa siêu nhỏ xếp lớp trùng điệp. Cấu trúc phẳng này tăng diện tích tiếp xúc quang tử lên gấp nhiều lần, giúp hấp thụ ánh sáng với độ chính xác quang học tuyệt đối và triệt tiêu gần như hoàn toàn cảm giác về hạt nhiễu khi nhìn bằng mắt thường.",
        "h2_2": "Độ bão hòa màu rực rỡ và độ phân giải quang học siêu cao",
        "p2_1": "Nếu như cuộn phim Kodak Portra 400 được tôn sùng vì khả năng tái tạo màu da êm dịu, thì Ektar 100 lại là 'vua của nhiếp ảnh phong cảnh'. Độ bão hòa màu sắc (saturation) của Ektar được đẩy lên mức cao nhất trong toàn bộ các dòng phim âm bản C-41. Những mảng đất đỏ bazan, vách đá sa thạch miền duyên hải hay màu nước biển xanh ngọc bích hiện lên với một độ no màu rực rỡ, sống động tựa như một bức tranh khắc họa thiên nhiên kỳ vĩ.",
        "p2_2": "Tuy nhiên, sức mạnh này cũng đi kèm với một yêu cầu khắt khe: Ektar 100 có độ tương phản khá dốc và cực kỳ nhạy cảm với nguồn sáng không chuẩn. Nếu chụp chân dung dưới ánh đèn vàng hoặc bóng râm gắt, màu da nhân vật rất dễ bị ám đỏ hoặc ánh cam rực quá đà. Đây là cuộn phim dành riêng cho những ngày trời xanh mây trắng rực rỡ và những góc nhìn phong cảnh hoành tráng.",
        "h2_3": "Chinh phục vẻ đẹp rực rỡ cùng RfCamera",
        "p3_1": "Khi kích hoạt cấu hình màu sắc tương ứng trong RfCamera, ma trận màu sắc tái hiện chính xác đáp ứng quang phổ của nhũ tương Ektar 100: các gam màu đỏ đất (terracotta red) và xanh lam đậm (deep ocean cyan) được tăng cường độ rực rỡ, đồng thời giữ cho các chi tiết đường chân trời ở vô cực luôn sắc nét như dao cạo.",
        "p3_2": "Nhờ đường ống xử lý tín hiệu không nén trên bộ nhớ GPU, ảnh chụp từ RfCamera bảo toàn nguyên vẹn độ chuyển màu vi điểm mềm mại giữa ánh nắng hoàng hôn và bóng đổ sườn núi, mang lại những bức ảnh phong cảnh du lịch lộng lẫy và đĩnh đạc như được tráng quét từ một cuộn phim chuyên nghiệp đắt giá."
    },

    # 10. Redscale (VN)
    {
        "slug": "ky-thuat-redscale-nhuong-sac-hoang-hon",
        "lang": "vi",
        "category": "Kỹ thuật sáng tạo",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "title": "Phim Redscale: Lộn Ngược Đáy Nhũ Tương Đón Sắc Đỏ Rực Lửa",
        "desc": "Khám phá kỹ thuật chụp phim Redscale độc đáo: cuốn ngược bề mặt phim để ánh sáng đi xuyên từ lớp đáy, tạo nên tông màu đỏ rực hổ phách ma mị và đầy tính biểu cảm.",
        "hero": "../assets/blog/redscale-crimson-sunset.jpg",
        "hero_caption": "Bầu trời thành phố rực lửa như ngày tận thế qua lăng kính của cuộn phim Redscale độc đáo.",
        "img1": "../assets/blog/redscale-crimson-sunset.jpg",
        "img1_caption": "Cây cầu sắt và dòng sông phản chiếu sắc cam hổ phách ma mị dưới ánh tà dương.",
        "img2": "../assets/blog/anamorphic-night-flares.jpg",
        "img2_caption": "Các nguồn sáng nhân tạo trong đêm khi chụp qua phim Redscale biến thành những vệt lửa ấm áp.",
        "img3": "../assets/samples/sample_traindoor.jpg",
        "img3_caption": "Tính ngẫu hứng và phá cách của Redscale biến mọi khung cảnh quen thuộc thành một thế giới siêu thực.",
        "h2_1": "Cơ chế đảo ngược ba lớp nhũ tương màu sắc",
        "p1_1": "Một cuộn phim màu âm bản 35mm thông thường bao gồm ba lớp nhũ tương hóa học xếp chồng lên nhau trên một đế nhựa trong suốt (acetate base). Theo thứ tự thiết kế tiêu chuẩn từ trên xuống dưới, ánh sáng sẽ đi qua lớp nhạy sáng Xanh lam (Blue), qua một màng lọc màu vàng, rồi đến lớp Xanh lục (Green) và cuối cùng là lớp Đỏ (Red) ở sát đáy. Kỹ thuật Redscale đảo lộn hoàn toàn trật tự quang học này bằng cách tháo cuộn phim trong buồng tối và cuốn ngược mặt phim lại, sao cho đế nhựa quay ra phía trước hướng về ống kính.",
        "p1_2": "Khi bạn bấm chụp, chùm sáng buộc phải đi xuyên qua lớp đế nhựa màu cam trước, sau đó đập trực tiếp vào lớp nhạy sáng Đỏ đầu tiên. Lớp nhũ tương đỏ nhận trọn vẹn 100% năng lượng ánh sáng và bị phơi sáng quá mức (heavily overexposed), trong khi năng lượng của các bước sóng xanh lục và xanh lam bị lớp lọc đế nhựa chặn lại gần như hoàn toàn. Kết quả là toàn bộ bức ảnh bị nhuộm một màu đỏ rực, cam cháy và vàng hổ phách vô cùng ấn tượng.",
        "h2_2": "Kiểm soát độ biến thiên màu sắc thông qua nấc phơi sáng",
        "p2_1": "Điều thú vị nhất của phim Redscale chính là màu sắc cuối cùng phụ thuộc hoàn toàn vào mức độ phơi sáng mà bạn lựa chọn. Nếu bạn chụp cuộn phim ISO 200 ở đúng mốc ISO 200 (hoặc thiếu sáng nhẹ), bức ảnh tráng ra sẽ mang một màu đỏ thẫm đen kịt như máu, với độ tương phản gắt gao và bóng tối sâu thẳm đầy bí ẩn.",
        "p2_2": "Nhưng nếu bạn cố tình phơi sáng dư từ +2 đến +3 stop (ví dụ cài đặt máy đo sáng ở mốc ISO 25 hoặc 50 trên cuộn phim 200), ánh sáng mạnh mẽ sẽ bắt đầu xuyên thủng qua lớp đáy đỏ để chạm tới lớp nhũ tương xanh lục. Khi đó, sắc đỏ rực sẽ dịu lại và chuyển hóa thành những gam màu vàng mù tạt, cam san hô và vàng mơ ấm áp, mang lại một không gian thị giác mơ màng tựa như một giấc chiêm bao mùa thu xưa cũ.",
        "h2_3": "Thử nghiệm sắc đỏ biểu cảm an toàn với RfCamera",
        "p3_1": "Tự làm một cuộn phim Redscale tại nhà đòi hỏi người chơi phải có túi đen buồng tối, kẹp rút lưỡi phim và kỹ năng dán băng dính nối phim chính xác nếu không muốn kẹt bánh răng buồng máy giữa chừng. Hơn nữa, việc phơi sáng sai một chút có thể làm hỏng toàn bộ cả cuộn phim 36 kiểu.",
        "p3_2": "Trong RfCamera, phong cách Redscale được tích hợp sẵn như một camera độc lập: ứng dụng mô phỏng chính xác đường cong biến thiên từ đỏ rực sang vàng hổ phách theo từng nấc thanh trượt phơi sáng EV trên giao diện. Bạn có thể thoải mái kéo sáng, ngắm nhìn hiệu ứng rực lửa chuyển động theo thời gian thực trên màn hình và bấm chụp những tác phẩm phố đêm hay chân dung siêu thực đầy cá tính."
    },

    # 11. Rangefinder Optics (EN)
    {
        "slug": "the-anatomy-of-leica-rangefinder-optics",
        "lang": "en",
        "category": "Optical Science",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "title": "The Optical Geometry of Rangefinders: Split-Image Coincidence in 35mm",
        "desc": "An engineering teardown of the mechanical rangefinder mechanism: triangular optical triangulation, beam-splitters, moving mirrors, and split-image coincidence focusing.",
        "hero": "../assets/blog/leica-m3-rangefinder.jpg",
        "hero_caption": "Mechanical precision: The dual optical windows of a vintage 35mm rangefinder system.",
        "img1": "../assets/blog/leica-m3-rangefinder.jpg",
        "img1_caption": "Satin chrome top plate housing the intricate glass prisms and mirrors of the coincidence rangefinder.",
        "img2": "../assets/blog/rangefinder-table-sunlight.jpg",
        "img2_caption": "Natural window light accentuating the physical dials and knurled focus helical.",
        "img3": "../assets/screenshots/01-camera.png",
        "img3_caption": "RfCamera's live rangefinder viewfinder recreates the unobstructed environmental perspective.",
        "h2_1": "Triangulation Physics and the Geometric Baseline",
        "p1_1": "Unlike Single-Lens Reflex (SLR) cameras that view the world through the shooting lens via a swinging reflex mirror, a rangefinder operates as an autonomous optical triangulation instrument. The mechanism relies on two separate windows positioned along the top plate of the camera: the primary viewfinder window on the right and a secondary rangefinder window spaced several centimeters to the left. The linear distance between the centers of these two entrance apertures is defined as the physical baseline (b).",
        "p1_2": "When light rays from a subject enter both windows simultaneously, the ray entering the secondary window is reflected across a rotating mirror or pivoting glass prism directly toward a semi-transparent beam-splitter located in front of the photographer's eye. By mechanically coupling this pivoting mirror to the helical focusing ring of the taking lens via a hardened cam follower arm, the device constructs a precise right-angled triangle where the subject's physical distance (D) is calculated by the angle of optical convergence.",
        "h2_2": "Effective Baselines and the 50mm f/1.4 Focusing Threshold",
        "p2_1": "The mechanical accuracy of any rangefinder camera is governed by its Effective Base Length (EBL), calculated by multiplying the physical distance between windows by the optical magnification factor of the viewfinder eyepiece (EBL = physical baseline × magnification). A wider baseline coupled with high eyepiece magnification generates a greater angular displacement for the split image, allowing human ocular vernier acuity to resolve microscopic discrepancies in focus.",
        "p2_2": "For high-speed portrait lenses such as a 50mm f/1.4 or 75mm f/1.4 wide open, where the depth of field at 1 meter is thinner than a fingernail, an EBL exceeding 55mm is mathematically required to guarantee critical focus. If the rangefinder cam arm is misaligned by even 5 microns due to an impact or worn lubricant, the coincidence patch will report perfect alignment while the actual focal plane drifts several centimeters behind the subject's eyelashes.",
        "h2_3": "Translating Mechanical Triangulation into Touchscreen Software",
        "p3_1": "Building RfCamera meant solving a fundamental philosophical question: how do you honor the visceral tactility of a mechanical rangefinder on a smooth smartphone screen? We rejected flat digital autofocus squares in favor of recreating the actual spatial experience of looking through optical glass. Outside the 35mm frame lines, the scene remains visible but subtly dimmed and softly blurred, allowing photographers to monitor emerging human drama before it steps into the frame.",
        "p3_2": "When adjusting the manual focal tray (26mm / 35mm / 50mm), the interface triggers fine micro-haptic clicks timed to the virtual helical teeth, while the acoustics replicate the quiet, breath-like sweep of a rubberized cloth focal-plane shutter, returning intentionality and contemplative joy to mobile image-making."
    },

    # 12. Kodak Tri-X Monochrome Mastery (EN)
    {
        "slug": "kodak-tri-x-monochrome-grain-mastery",
        "lang": "en",
        "category": "Film Stocks",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "title": "Kodak Tri-X 400 at Night: High-Acutance Grain and Push Processing",
        "desc": "Mastering Kodak Tri-X 400 black and white film in low light: developer chemistry, push processing to ISO 1600, micro-contrast, and silver grain structure.",
        "hero": "../assets/blog/street-monochrome-tri-x.jpg",
        "hero_caption": "Nocturnal street scene in rain, rendered with deep blacks and gritty silver grain characteristic of pushed Tri-X.",
        "img1": "../assets/blog/street-monochrome-tri-x.jpg",
        "img1_caption": "Pavement reflections and umbrella silhouettes carved out by high-acutance silver halide crystals.",
        "img2": "../assets/samples/sample_street.jpg",
        "img2_caption": "Everyday street life reduced to light, shadow, and emotional geometry without color distraction.",
        "img3": "../assets/blog/leica-m3-rangefinder.jpg",
        "img3_caption": "The compact rangefinder and 400-speed monochrome film: the quintessential documentary tool.",
        "h2_1": "The Chemistry of High-Acutance Silver Halide Grain",
        "p1_1": "Introduced in 1954, Kodak Professional Tri-X 400 remains the defining aesthetic voice of documentary photojournalism. Unlike contemporary tabular-grain films that emphasize clinical smoothness, Tri-X retains a traditional cubic silver halide crystal emulsion. These crystals are distributed throughout multiple depth layers within the gelatin matrix, producing an optical response known as high acutance — a razor-sharp perceptual edge contrast that makes textures leap from the printed page.",
        "p1_2": "When developed in classic chemistry like Kodak D-76 diluted 1:1 or Rodinal at high dilution, the edges of adjacent bright and dark areas experience localized chemical exhaustion. Potassium bromide released from heavily exposed highlight regions diffuses across the boundary into the adjacent shadow area, creating micro-density border effects that human vision interprets as crisp physical dimensionality.",
        "h2_2": "The Mechanics of Push Processing to ISO 1600 and 3200",
        "p2_1": "In low-light street photography, where streetlamps provide the sole illumination, shooting at nominal box speed leads to unrecoverable motion blur. Push processing exploits the remarkable chemical latitude of Tri-X. By rating the roll at ISO 1600 in the camera's meter and extending darkroom development time by 40% to 50%, the photographer forces sub-surface silver crystals in the midtones to develop fully into metallic silver.",
        "p2_2": "This chemical forcing compresses the tonal scale into a fierce, graphic dynamic: deep shadows drop straight into pitch black, highlights burn bright and clean, and the silver grain clumps together into gritty, tactile clusters. This bold look defined the post-war Japanese street photography movement, capturing urban grit and existential urgency with unvarnished honesty.",
        "h2_3": "Digital Emulation Without Flat Desaturation",
        "p3_1": "Most mobile camera apps convert photos to black and white by simply dragging the saturation slider to zero — a lazy shortcut that flattens skin tones into muddy grey sludge. In RfCamera, the GR-D monochrome emulator executes a specialized spectral matrix that mimics an analog orange contrast filter, darkening blue skies and brightening human facial tones to preserve healthy skin radiance.",
        "p3_2": "Simultaneously, our fragment shader injects stochastic, resolution-independent film grain derived from physical film plate scans rather than repetitive pixel noise. The grain moves and breathes naturally, giving your mobile street photography the timeless dignity of darkroom silver gelatin prints."
    },

    # 13. Fujicolor C200 Palette Guide (EN)
    {
        "slug": "fujicolor-c200-pastel-greens-daylight-guide",
        "lang": "en",
        "category": "Film Stocks",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "title": "Fujicolor C200 Daylight Palette: Soft Greens, Cyan Skies, and Clean Shadows",
        "desc": "A technical study of Fujicolor C200 35mm film: spectral sensitivity, emerald green foliage rendering, shadow cyan color casts, and summer nostalgic aesthetics.",
        "hero": "../assets/blog/fujicolor-summer-greens.jpg",
        "hero_caption": "Suburban Tokyo neighborhood bathed in soft afternoon sun, exhibiting Fujicolor's signature mint-green foliage.",
        "img1": "../assets/blog/fujicolor-summer-greens.jpg",
        "img1_caption": "Soft highlight rolloff and clean cyan skies deliver an airy, nostalgic summer mood.",
        "img2": "../assets/samples/sample_field.jpg",
        "img2_caption": "Open fields rendered with subtle color gradation rather than overcooked digital saturation.",
        "img3": "../assets/blog/rangefinder-table-sunlight.jpg",
        "img3_caption": "Affordable, reliable, and expressive: C200 was the backbone of casual analog photography for decades.",
        "h2_1": "Fujifilm's Proprietary Cyan-Green Spectral Bias",
        "p1_1": "Color negative film is not a neutral mirror of optical reality; it is a carefully calibrated chemical interpretation of light. Where Kodak emulsions historically leaned toward golden warmth to flatter Caucasian skin under North American sun, Fujifilm engineered Fujicolor C200 with an explicit sensitivity toward the cool end of the visible spectrum. Green foliage, moss, and shadows receive a delicate cyan-tinted boost that feels fresh, airy, and inherently peaceful.",
        "p1_2": "This characteristic stems from Fujifilm's advanced dye coupler technology, which prevents red and yellow dyes from bleeding into adjacent emulsion layers under harsh noon sunlight. As a result, lush summer foliage maintains its distinct leaf-to-leaf separation without collapsing into a uniform brownish-green smear, creating the signature 'Japanese Summer Aesthetic' celebrated in contemporary cinema.",
        "h2_2": "Shadow Color Casts and Highlight Softness",
        "p2_1": "One of C200's most recognizable quirks is how it behaves in indirect illumination. While brightly lit areas remain remarkably true to life with soft, pastel skin tones, areas falling into open shade or covered alleyways take on a subtle pastel cyan-blue wash. This occurs because the blue- and green-sensitive emulsion layers possess slightly steeper characteristic curves in the toe region than the red layer.",
        "p2_2": "Rather than appearing as a technical defect, this cool shadow cast introduces emotional atmosphere into mundane street corners. The highlight shoulder rolls off with exceptional gentleness, ensuring that brightly lit concrete sidewalks and whitewashed walls retain delicate textural details rather than clipping into harsh digital white patches.",
        "h2_3": "Experiencing Japanese Analog Color in RfCamera",
        "p3_1": "To reproduce C200's delicate optical charm, RfCamera processes the camera sensor feed through a calibrated color matrix running on background GPU isolates. The green channel gain is subtly elevated in the midtones while the shadow floor is mapped to an RGB ratio favoring cool cyan, exactly replicating the chemical response of Fuji's C-41 negative stock.",
        "p3_2": "Because the entire pipeline runs locally on your device without transmitting image data over the network, your private moments and travel snapshots are rendered with artisanal analog integrity while your personal data stays 100% offline and secure."
    },

    # 14. Double Exposure Analog Technique (EN)
    {
        "slug": "double-exposure-composition-analog-technique",
        "lang": "en",
        "category": "Creative Techniques",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "title": "Double Exposure Dynamics: Additive Latent Images on 35mm Silver Halide",
        "desc": "Mastering analog double exposure photography: cumulative photon absorption, silhouette masking strategies, intentional underexposure, and surreal compositing.",
        "hero": "../assets/blog/double-exposure-portrait.jpg",
        "hero_caption": "Surreal in-camera double exposure combining a feminine silhouette with mountain pines and atmospheric mist.",
        "img1": "../assets/blog/double-exposure-portrait.jpg",
        "img1_caption": "The deep shadow values of the profile act as a clean photographic canvas for the secondary exposure.",
        "img2": "../assets/samples/sample_beach.jpg",
        "img2_caption": "Sunlit sea foam and wave crests make excellent high-frequency textures for secondary overlapping.",
        "img3": "../assets/blog/macro-film-dewdrop.jpg",
        "img3_caption": "Macro botanical patterns can be layered over architecture to create dreamlike organic collages.",
        "h2_1": "The Additive Physics of Latent Image Formation",
        "p1_1": "In physical film photography, a double exposure is created by intentionally exposing the exact same 36x24mm rectangle of silver halide emulsion to light twice before advancing the roll. At the atomic scale, latent image formation is an irreversible additive process: photons striking silver bromide crystals release electrons that reduce silver ions (Ag+) into sub-microscopic clusters of metallic silver (Ag0). Each successive exposure can only add further silver nuclei; it can never subtract or erase what has already landed.",
        "p1_2": "This fundamental law dictates that any section of the frame exposed to pure white in the first shot has exhausted its available silver halide. When the second shutter fires, no further latent density can form in those burned-out regions. Consequently, double exposure composition is not about stacking two complete pictures — it is about orchestrating light in one image to fill the darkness of another.",
        "h2_2": "Silhouette Masking and Exposure Compensation Rules",
        "p2_1": "The most effective double exposure compositions utilize a stark silhouette as an organic stencil. Photographing a model directly against a bright sky or window casts their face and torso into deep shadow. These underexposed dark areas leave the underlying silver crystals untouched, creating a pristine canvas primed to record the textures, trees, or city architecture captured during the second shutter release.",
        "p2_2": "To maintain correct overall density across the final negative, photographers apply the rule of exposure compensation: shooting both exposures at nominal box speed results in an overexposed negative (+1 EV total exposure). Setting your camera's exposure compensation dial to -1 EV for both shots ensures that when their respective photon counts combine, the resulting negative lands precisely on the linear portion of the film's characteristic curve.",
        "h2_3": "Real-Time Ghost Layering with RfCamera",
        "p3_1": "Executing double exposures on mechanical film cameras historically required delicate guesswork and nerve-wracking film rewinding tricks that often misaligned frame edges. RfCamera eliminates the blind trial-and-error while preserving the authentic physics of optical blend modes.",
        "p3_2": "After taking your first frame, the app renders a subtle semi-transparent ghost preview over your live rangefinder viewfinder. You can leisurely pan, tilt, and frame your second subject — aligning a distant skyline into the hollow of a silhouette with pinpoint compositional precision before committing to the shot."
    },

    # 15. Anamorphic Blue Streak Flares (EN)
    {
        "slug": "anamorphic-horizontal-streak-flares-physics",
        "lang": "en",
        "category": "Optical Science",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "title": "Cylindrical Optics: The Physical Mechanics of Anamorphic Blue Streak Flares",
        "desc": "How cylindrical glass optical elements squeeze widescreen perspectives, generate horizontal blue streak lens flares, and produce oval out-of-focus bokeh.",
        "hero": "../assets/blog/anamorphic-night-flares.jpg",
        "hero_caption": "Cinematic nighttime streetscape characterized by prominent horizontal cyan flares across street lanterns.",
        "img1": "../assets/blog/anamorphic-night-flares.jpg",
        "img1_caption": "Horizontal flare lines stretch completely across the 2.39:1 widescreen frame, providing high cinematic drama.",
        "img2": "../assets/samples/sample_traindoor.jpg",
        "img2_caption": "Light grazing train compartment glass mimics the internal reflections of vintage optical coatings.",
        "img3": "../assets/screenshots/06-quick-panel.png",
        "img3_caption": "RfCamera's quick settings panel allows instant toggling between classic 35mm and widescreen aspect ratios.",
        "h2_1": "The Geometry of Cylindrical Glass and 2:1 Optical Squeeze",
        "p1_1": "Standard photographic lenses employ rotationally symmetric spherical elements that treat light rays identically along both the horizontal and vertical axes. Anamorphic lenses break this symmetry by introducing cylindrical optical elements — glass surfaces curved along the horizontal plane while remaining completely flat along the vertical plane. This unique geometry bends incoming light rays horizontally by a factor of 2.0x, optically squeezing a broad panoramic view into a standard 35mm camera frame.",
        "p1_2": "During theatrical projection or modern digital de-squeezing, the image is stretched back out to its native 2.39:1 aspect ratio. This process grants filmmakers an expansive field of view equivalent to a wide-angle lens along the horizontal axis, while preserving the shallow depth of field, natural perspective compression, and lack of facial distortion typical of a longer focal length along the vertical axis.",
        "h2_2": "Internal Reflections, Lens Coatings, and Streak Mechanics",
        "p2_1": "The iconic horizontal streak flares that have defined sci-fi cinema and prestige filmmaking are an inherent byproduct of cylindrical glass geometry. When an intense point source of light enters the front of the lens at an angle, light reflects back and forth between the air-glass boundaries of the curved cylindrical elements. Because the horizontal curvature acts as a continuous cylindrical mirror, the reflected light is focused into a razor-thin horizontal line stretching across the entire width of the frame.",
        "p2_2": "The striking cobalt-blue hue of vintage anamorphic flares is determined by the anti-reflective chemical coatings applied to the glass elements. Vintage lenses from the 1960s used single-layer magnesium fluoride coatings designed to optimize transmission of warm light, causing unabsorbed high-frequency blue wavelengths to reflect internally and emerge as vibrant cyan streaks.",
        "h2_3": "Shader-Based Optical Synthesis in RfCamera",
        "p3_1": "Real anamorphic lenses weigh several kilograms and require specialized follow-focus gears. RfCamera simulates this cinema magic entirely inside a custom GLSL fragment shader running in real time at 60 frames per second. The shader isolates specular highlight pixels exceeding luminance threshold 0.85 and applies a directional 1D Gaussian kernel along the horizontal scanline.",
        "p3_2": "Coupled with barrel distortion at the frame perimeter and oval bokeh weighting, RfCamera delivers genuine Hollywood anamorphic atmosphere directly to your phone screen — entirely offline, completely subscription-free, and requiring zero bulky glass adapters."
    },

    # 16. Hasselblad Ground Glass Ritual (EN)
    {
        "slug": "hasselblad-waist-level-ground-glass-ritual",
        "lang": "en",
        "category": "Camera Lore",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "title": "Ground-Glass Contemplation: The Square Frame of the Hasselblad 500C/M",
        "desc": "Examining the contemplative ritual of medium format photography: waist-level framing, lateral image reversal on ground glass, and the discipline of 6x6 squares.",
        "hero": "../assets/blog/hasselblad-waist-level.jpg",
        "hero_caption": "Looking straight down into the waist-level finder of a Hasselblad 500C/M with landscape framed on ground glass.",
        "img1": "../assets/blog/hasselblad-waist-level.jpg",
        "img1_caption": "The four-sided metal pop-up hood shields ambient skylight, allowing critical evaluation of matte glass contrast.",
        "img2": "../assets/blog/hasselblad-waist-level-alt.jpg",
        "img2_caption": "Fine crosshair grid lines aid architectural leveling and formal balance across the 1:1 format.",
        "img3": "../assets/samples/sample_field.jpg",
        "img3_caption": "Medium format negates the scramble between horizontal and vertical, imposing absolute calm on the composition.",
        "h2_1": "Waist-Level Viewing and the Subversion of Eye-Level Dominance",
        "p1_1": "Bringing a camera to eye level is an assertive, sometimes intrusive act that fundamentally alters the dynamic between the photographer and their subject. The waist-level finder (WLF) of the classic Hasselblad 500C/M transforms picture-making into an act of quiet deference. With the camera suspended at belly level by a leather strap, the photographer looks downward into a leather-lined chimney hood, their head bowed in contemplation as if consulting an illuminated manuscript.",
        "p1_2": "Subjects react to this posture with relaxed candor. Because the photographer's eyes are not hidden behind a glass eyepiece, direct human eye contact can be maintained until the moment of shutter release. The lowered vantage point naturally elevates the subject's stature, lending portraits an innate dignity and landscapes a grounded, architectural stability.",
        "h2_2": "The Lateral Inversion Phenomenon and 6x6 Square Discipline",
        "p2_1": "Because light from the reflex mirror bounces directly upward onto the underside of the ground-glass focusing screen without passing through a corrective roof pentaprism, the viewfinder image is laterally reversed: subjects walking to the left appear on screen moving to the right. While disorienting for the first few rolls of 120 film, this optical reversal serves a profound compositional purpose.",
        "p2_2": "By detaching the visual representation from everyday cognitive muscle memory, lateral inversion forces the photographer's brain to evaluate the image as pure geometric design. You no longer see a street corner; you see intersecting diagonal vectors, weight distributions, and negative space. Combined with the non-directional harmony of the 6x6cm square, every element inside the frame must justify its existence.",
        "h2_3": "The S67 Aesthetic Pipeline in RfCamera",
        "p3_1": "In RfCamera, the S67 camera profile pays reverent homage to the medium format legacy. Framing photos through the square 1:1 aspect ratio invokes custom shader-driven edge falloff and subtle vignetting characteristic of legendary Carl Zeiss Planar 80mm f/2.8 glass.",
        "p3_2": "When the shutter button is touched, our synthesized acoustics reproduce the twin clatter of the auxiliary rear barn doors and the damping dashpot mechanism, delivering the unmistakable mechanical authority of Swedish medium format precision right into your palm."
    },

    # 17. Macro Film Physics (EN)
    {
        "slug": "macro-film-optics-bellows-extension-factor",
        "lang": "en",
        "category": "Optical Science",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "title": "Macro Film Physics: Bellows Extension, Inverse-Square Falloff, and Bokeh",
        "desc": "Technical breakdown of extreme close-up analog photography: bellows light loss calculation, razor-thin focal planes, and specular bubble bokeh.",
        "hero": "../assets/blog/macro-film-dewdrop.jpg",
        "hero_caption": "Extreme close-up study of morning dew on pine needles, rendered with soft circular specular bubbles.",
        "img1": "../assets/blog/macro-film-dewdrop.jpg",
        "img1_caption": "Sub-millimeter depth of field isolates the central dewdrop while foreground needles dissolve into creamy blur.",
        "img2": "../assets/samples/sample_leaf.png",
        "img2_caption": "Intricate cellular veins in plant leaves captured with smooth, non-aliased micro-tonal gradation.",
        "img3": "../assets/blog/leica-m3-rangefinder.jpg",
        "img3_caption": "Rangefinder cameras require auxiliary optical visoflex attachments to conquer the macro realm.",
        "h2_1": "The Mathematics of Bellows Extension Light Falloff",
        "p1_1": "When focusing on distant objects at infinity, the distance between the rear optical nodal point of a lens and the film plane equals the lens's nominal focal length (f). In macro photography, achieving life-size 1:1 magnification requires moving the entire lens assembly forward by an additional focal length, doubling the total distance between glass and film. Under the inverse-square law, doubling the distance quartered the illuminance reaching the emulsion, causing an unavoidable 2-stop loss of light.",
        "p1_2": "This geometric loss is formalized by the effective aperture equation: f_effective = f_nominal × (1 + magnification). At 1:1 magnification (m = 1), a lens physically set to f/4 operates with the light-gathering throughput of f/8. In mechanical film photography, failure to calculate and manually compensate for this extension factor will inevitably ruin the roll through severe underexposure.",
        "h2_2": "Managing Sub-Millimeter Depth of Field",
        "p2_1": "At 1:1 reproduction ratios, depth of field shrinks to microscopic fractions of a millimeter. Even when stopping down to small apertures like f/16 to claw back sharpness, optical diffraction begins to soften edge acutance as light waves bend around the edges of the tiny aperture blades. The macro photographer must therefore accept that only a single paper-thin slice of the subject will achieve critical sharpness.",
        "p2_2": "This optical constraint elevates bokeh from an incidental background blur into a primary compositional protagonist. Out-of-focus highlights from specular water reflections transform into luminous circular discs whose perimeter softness is dictated by the lens's spherical aberration correction, bathing macro subjects in an ethereal, painterly glow.",
        "h2_3": "Micro-Precision Experience in RfCamera",
        "p3_1": "RfCamera's macro simulation incorporates optical falloff calculations in its real-time viewport renderer. As you push close to subjects, the fragment shader computes the virtual lens displacement, ensuring that highlight compression and micro-grain visibility respond authentically to focal distance.",
        "p3_2": "By pairing this visual accuracy with localized haptic ticks when subjects align with the central focal plane, RfCamera gives mobile creators the surgical precision of a studio macro rail without the encumbrance of physical extension tubes."
    },

    # 18. Cyanotype Chemical Process (EN)
    {
        "slug": "cyanotype-sun-printing-chemical-process",
        "lang": "en",
        "category": "Alternative Processes",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "title": "Cyanotype and Sun Printing: The 1842 Alternative Chemical Process",
        "desc": "The chemical foundations of 19th-century cyanotype sun printing: iron salt photoreduction, Prussian Blue pigment formation, and handmade archival permanence.",
        "hero": "../assets/blog/cyanotype-botanical-print.jpg",
        "hero_caption": "Handmade botanical cyanotype print on cold-pressed paper showing crisp fern fronds against deep Prussian Blue.",
        "img1": "../assets/blog/cyanotype-botanical-print.jpg",
        "img1_caption": "Uncoated paper borders and hand-brushed emulsion marks underscore the unique tactile beauty of alternative processes.",
        "img2": "../assets/samples/sample_leaf.png",
        "img2_caption": "Photograms of pressed foliage were the earliest form of camera-less photographic reproduction.",
        "img3": "../assets/blog/rangefinder-table-sunlight.jpg",
        "img3_caption": "Pure sunlight remains the primary UV exposure engine for alternative darkroom artisans today.",
        "h2_1": "Photochemistry of Iron Salts and Solar UV Reduction",
        "p1_1": "Invented by Sir John Herschel in 1842, cyanotype is the preeminent non-silver photographic process. The photosensitive emulsion is synthesized by dissolving two benign iron compounds in water: ferric ammonium citrate (a light-sensitive organic iron salt) and potassium ferricyanide. When coated onto absorbent paper and dried in the dark, the paper appears a dull chartreuse-green.",
        "p1_2": "Upon exposure to natural solar ultraviolet radiation (UV-A wavelengths between 315 and 400 nm), the ferric ions (Fe3+) in the citrate complex absorb photon energy and undergo reduction to ferrous ions (Fe2+). These newly liberated ferrous ions immediately react with the potassium ferricyanide in the emulsion, synthesizing insoluble ferric ferrocyanide — the historic inorganic pigment known universally as Prussian Blue.",
        "h2_2": "Cold Water Processing and Archival Permanence",
        "p2_1": "Unlike silver halide prints that require caustic development baths, stop baths, and acidic thiosulfate fixers, a cyanotype is fully developed and fixed with nothing more than ordinary running water. Immersing the exposed paper in water dissolves and flushes away the unexposed, water-soluble iron salts from the paper fibers, leaving behind pure white highlights.",
        "p2_2": "As the insoluble Prussian Blue pigment oxidizes in ambient air over the subsequent 24 hours, the shadows deepen into a rich, luminous cerulean. Because Prussian Blue is completely immune to sulfur fumes and atmospheric pollutants that cause silver prints to yellow and fade over time, properly washed cyanotypes stored away from alkaline conditions can endure for centuries with zero loss of tonal brilliance.",
        "h2_3": "Historical Aesthetics Preserved in RfCamera",
        "p3_1": "RfCamera's Prussian Blue monochrome profile translates this 1842 optical legacy into the digital age. Rather than a simple blue color tint overlay, our rendering pipeline maps image luminance values across the specific spectrophotometric curve of iron ferrocyanide, lifting shadow values into deep indigo while holding delicate highlights in creamy paper white.",
        "p3_2": "With simulated rag paper deckle edges and organic tonal gradation, RfCamera offers mobile creators a gateway to early Victorian photographic history directly from their modern smartphone."
    },

    # 19. Kodak Ektar 100 Architecture (EN)
    {
        "slug": "kodak-ektar-100-ultrafine-grain-architecture",
        "lang": "en",
        "category": "Film Stocks",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "title": "Kodak Ektar 100: Micro-Structure, T-Grain Emulsion, and Coastal Saturation",
        "desc": "Deep technical analysis of Kodak Ektar 100 color negative film: RMS 25 granularity, advanced T-Grain architecture, high color saturation, and landscape fidelity.",
        "hero": "../assets/blog/kodak-ektar-cliffs.jpg",
        "hero_caption": "Golden hour coastal cliffs plunging into turquoise Pacific waters, exhibiting Kodak Ektar's extraordinary saturation.",
        "img1": "../assets/blog/kodak-ektar-cliffs.jpg",
        "img1_caption": "Ultra-sharp horizon separation and rich terracotta cliff hues captured without pixelation or digital noise.",
        "img2": "../assets/samples/sample_beach.jpg",
        "img2_caption": "Ocean foam and sea spray rendered with pristine micro-tonal separation across the highlights.",
        "img3": "../assets/samples/sample_palm.jpg",
        "img3_caption": "Deep jungle greens and rich cyan sky tones shine under bright midday sun.",
        "h2_1": "Tabular T-Grain Technology and RMS 25 Granularity",
        "p1_1": "Introduced in 2008, Kodak Professional Ektar 100 holds the distinction of being the finest-grained color negative film ever manufactured for 35mm cameras. Its extraordinary resolution is made possible by Kodak's proprietary Tabular Grain (T-Grain) technology. While conventional silver halide crystals possess random spherical shapes that scatter incoming photons, T-Grain crystals are synthesized with flat, micro-thin hexagonal tablet geometries.",
        "p1_2": "These flattened crystals lie parallel to the film base, presenting a massive surface area to incoming light while occupying minimal depth. This configuration achieves an astonishing Diffuse RMS Granularity rating of 25 — a figure so microscopic that 35mm negatives can be drum-scanned at 4000 DPI to produce 40-megapixel digital files displaying virtually zero perceptible grain structure in the sky and smooth gradients.",
        "h2_2": "Hyper-Vivid Chromatic Response for Landscape Optics",
        "p2_1": "Where portrait films like Kodak Portra 400 feature lower contrast curves to ensure gentle skin gradations, Ektar 100 is intentionally engineered with high contrast and hyper-vivid color couplers. Red, cyan, and gold tones are amplified to deliver breathtaking visual punch, making it the undisputed champion for landscape, travel, and commercial architecture photography.",
        "p2_2": "However, this aggressive saturation demands meticulous exposure hygiene. Ektar possesses a narrower latitude than other color negative stocks, punishing underexposure with muddy cyan shadows and overexposure with warm magenta shifts. Photographers treat Ektar like color slide film, metering precisely for midtone values to lock in its legendary chromatic brilliance.",
        "h2_3": "High-Fidelity Landscape Emulation in RfCamera",
        "p3_1": "RfCamera recreates Ektar's demanding elegance through a specialized high-gamut color transform matrix. By expanding color saturation in the cyan and warm amber spectra while tightening the shoulder compression curve, our app delivers the commanding visual stature of fine-grain analog landscape film.",
        "p3_2": "Every shot taken in Ektar mode preserves full-resolution optical clarity through isolate-backed image baking, providing pristine, frame-ready landscape photos without relying on cloud processing or recurring subscription fees."
    },

    # 20. Redscale Physics (EN)
    {
        "slug": "redscale-reversed-emulsion-physics",
        "lang": "en",
        "category": "Creative Techniques",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "title": "Redscale Physics: Inverse Layer Penetration and Chromatic Shift",
        "desc": "The optical and chemical physics of redscale film: reversing color negative film inside the cartridge, orange base filtration, and fiery amber urban photography.",
        "hero": "../assets/blog/redscale-crimson-sunset.jpg",
        "hero_caption": "Urban skyline illuminated in dramatic fiery crimson and molten gold tones via inverted redscale exposure.",
        "img1": "../assets/blog/redscale-crimson-sunset.jpg",
        "img1_caption": "Bridge structures and river reflections bathe in monochromatic amber, converting ordinary cities into alien vistas.",
        "img2": "../assets/blog/anamorphic-night-flares.jpg",
        "img2_caption": "Artificial point lights produce intense orange halation and glowing halos when striking inverted film layers.",
        "img3": "../assets/samples/sample_traindoor.jpg",
        "img3_caption": "Interior scenes take on a mysterious, dreamlike vintage cinematic mood under redscale color shifts.",
        "h2_1": "Inverting the Color Multi-Layer Architecture",
        "p1_1": "A standard C-41 color negative film consists of a layered sandwich: a protective top coat, a blue-sensitive emulsion layer, a yellow colloidal silver filter layer to absorb remaining blue light, a green-sensitive layer, and finally a red-sensitive layer resting atop the clear triacetate or polyester base. Redscale photography fundamentally subverts this hierarchy by winding the film backward into the canister so that the plastic base faces the lens instead of the emulsion.",
        "p1_2": "During exposure, light is forced to penetrate the plastic base first. Because color negative film base is impregnated with an orange masking dye to compensate for dye coupler impurities, this base acts as an intense physical warm-color filter. It absorbs virtually all high-frequency blue and violet light before the rays can ever reach the photosensitive layers below, radically skewing the color balance of the recorded latent image.",
        "h2_2": "Exposure-Dependent Chromatic Transformations",
        "p2_1": "The defining charm of redscale lies in its dramatic exposure dependency. Because the red-sensitive layer is the first emulsion layer struck by the incoming light, it receives maximum optical energy. When shot at box speed or slightly underexposed, only the red layer receives sufficient photons to develop, resulting in stark monochromatic images dominated by blood red and charcoal blacks.",
        "p2_2": "When intentionally overexposed by +2 to +4 stops (for example, rating an ISO 400 film at ISO 50 or 25), intense light penetrates through the red layer and activates the green-sensitive layer beneath it. In the C-41 color development bath, the combined dyes produce radiant golden ambers, molten oranges, and warm mustard yellows, generating an otherworldly twilight aesthetic unattainable with standard digital filters.",
        "h2_3": "Safe Experimental Creativity with RfCamera",
        "p3_1": "Physically modifying film cartridges in a darkroom bag carries constant risks of scratching the delicate emulsion, inducing static discharge sparks, or jamming camera advance sprockets. RfCamera brings the unbridled experimental joy of redscale to your smartphone without the mechanical headaches.",
        "p3_2": "Our real-time GLSL shader accurately simulates the progressive red-to-gold color transition as you adjust the exposure compensation slider. You can observe the fiery transformation live in your viewfinder, crafting bold, unapologetic visual poetry while enjoying the peace of mind of an app that is 100% offline, private, and free."
    }
]

# HTML Template
def render_article_html(a):
    slug = a['slug']
    title = a['title']
    desc = a['desc']
    cat = a['category']
    date = a['date']
    read_time = a['readTime']
    hero = a['hero']
    hero_cap = a['hero_caption']
    img1 = a['img1']
    img1_cap = a['img1_caption']
    img2 = a['img2']
    img2_cap = a['img2_caption']
    img3 = a['img3']
    img3_cap = a['img3_caption']
    
    h2_1 = a['h2_1']
    p1_1 = a['p1_1']
    p1_2 = a['p1_2']
    
    h2_2 = a['h2_2']
    p2_1 = a['p2_1']
    p2_2 = a['p2_2']
    
    h2_3 = a['h2_3']
    p3_1 = a['p3_1']
    p3_2 = a['p3_2']
    
    # Back link label
    back_label = "<- Quay lại danh sách bài viết" if a['lang'] == 'vi' else "<- Back to Guides & Stories"
    cta_h3 = "Trải nghiệm nhiếp ảnh film 35mm đích thực trên điện thoại" if a['lang'] == 'vi' else "Experience Real 35mm Film in Your Pocket"
    cta_p = "12 thân máy cơ huyền thoại, shader quang học thời gian thực, 100% ngoại tuyến & miễn phí hoàn toàn." if a['lang'] == 'vi' else "12 classic analog cameras, live fragment shaders, and mechanical acoustics. 100% offline & free."
    author_role = "Đội ngũ biên tập RfCamera • Chuyên sâu về nhiếp ảnh analog 35mm, quang học và phần mềm ngoại tuyến." if a['lang'] == 'vi' else "Dedicated to pure analog 35mm film craft, optics, and 100% offline software."

    return f"""<!DOCTYPE html>
<html lang="{a['lang']}">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{title} - RfCamera Guides</title>
  <meta name="description" content="{desc}" />
  <meta name="keywords" content="{slug.replace('-', ', ')}, rfcamera, analog film, 35mm photography" />
  <link rel="canonical" href="https://rfcam.roycorp.xyz/blog/{slug}.html" />

  <!-- Open Graph -->
  <meta property="og:type" content="article" />
  <meta property="og:url" content="https://rfcam.roycorp.xyz/blog/{slug}.html" />
  <meta property="og:title" content="{title}" />
  <meta property="og:description" content="{desc}" />
  <meta property="og:image" content="https://rfcam.roycorp.xyz{hero.replace('..', '')}" />

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="{title}" />
  <meta name="twitter:description" content="{desc}" />
  <meta name="twitter:image" content="https://rfcam.roycorp.xyz{hero.replace('..', '')}" />

  <!-- Schema.org Article -->
  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "{title}",
    "description": "{desc}",
    "image": "https://rfcam.roycorp.xyz{hero.replace('..', '')}",
    "datePublished": "2026-08-28",
    "dateModified": "2026-08-28",
    "author": {{
      "@type": "Organization",
      "name": "RfCamera Editorial Team",
      "url": "https://rfcam.roycorp.xyz/"
    }},
    "publisher": {{
      "@type": "Organization",
      "name": "RfCamera",
      "url": "https://rfcam.roycorp.xyz/",
      "logo": {{
        "@type": "ImageObject",
        "url": "https://rfcam.roycorp.xyz/assets/rfcam_icon.png"
      }}
    }},
    "mainEntityOfPage": {{
      "@type": "WebPage",
      "@id": "https://rfcam.roycorp.xyz/blog/{slug}.html"
    }}
  }}
  </script>

  <style>
    :root {{
      --bg: #0A0A0D;
      --surface: #121217;
      --surface-card: #181820;
      --border: #262633;
      --border-focus: #4F4F66;
      --text: #F0F0F5;
      --text-muted: #8E8EA0;
      --text-dim: #5A5A6E;
      --accent: #E05A47;
      --accent-warm: #E5A93C;
      --font-mono: 'SF Mono', SFMono-Regular, ui-monospace, Menlo, Consolas, monospace;
      --font-sans: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    }}

    * {{ box-sizing: border-box; margin: 0; padding: 0; }}

    body {{
      background: var(--bg);
      color: var(--text);
      font-family: var(--font-sans);
      line-height: 1.7;
      -webkit-font-smoothing: antialiased;
      padding: 0 20px 80px;
    }}

    .article-wrap {{
      max-width: 780px;
      margin: 0 auto;
      padding-top: 50px;
    }}

    .back-link {{
      display: inline-flex;
      align-items: center;
      gap: 6px;
      color: var(--text-muted);
      text-decoration: none;
      font-size: 13.5px;
      font-weight: 500;
      margin-bottom: 30px;
      transition: color 0.15s ease;
    }}
    .back-link:hover {{ color: var(--text); }}

    .article-header {{
      margin-bottom: 32px;
    }}

    .badge-row {{
      display: flex;
      gap: 10px;
      align-items: center;
      margin-bottom: 14px;
      flex-wrap: wrap;
    }}

    .cat-badge {{
      background: rgba(224, 90, 71, 0.15);
      color: var(--accent);
      border: 1px solid rgba(224, 90, 71, 0.3);
      padding: 3px 10px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 600;
      letter-spacing: 0.5px;
      text-transform: uppercase;
    }}

    .mono {{ font-family: var(--font-mono); font-size: 12.5px; color: var(--text-muted); }}

    h1 {{
      font-size: clamp(26px, 4.5vw, 36px);
      font-weight: 800;
      line-height: 1.25;
      letter-spacing: -0.5px;
      margin-bottom: 16px;
      color: #fff;
    }}

    .hero-img-box {{
      width: 100%;
      border-radius: 14px;
      overflow: hidden;
      border: 1px solid var(--border);
      background: var(--surface);
      margin-bottom: 40px;
    }}
    .hero-img-box img {{
      width: 100%;
      height: auto;
      display: block;
      object-fit: cover;
      max-height: 480px;
    }}
    .img-caption {{
      padding: 10px 14px;
      font-size: 12px;
      color: var(--text-muted);
      background: var(--surface);
      border-top: 1px solid var(--border);
    }}

    .content-body {{
      display: flex;
      flex-direction: column;
      gap: 20px;
      font-size: 16px;
      color: #D6D6E0;
    }}

    .content-body h2 {{
      font-size: 22px;
      font-weight: 700;
      color: #fff;
      margin-top: 24px;
      margin-bottom: 4px;
      letter-spacing: -0.3px;
    }}

    .content-body p {{
      margin-bottom: 6px;
      line-height: 1.75;
    }}

    .inline-img-card {{
      border-radius: 12px;
      overflow: hidden;
      border: 1px solid var(--border);
      background: var(--surface);
      margin: 16px 0 24px;
    }}
    .inline-img-card img {{
      width: 100%;
      height: auto;
      display: block;
      max-height: 420px;
      object-fit: cover;
    }}

    .author-card {{
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 24px;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 14px;
      margin-top: 40px;
    }}
    .author-avatar {{
      width: 50px;
      height: 50px;
      border-radius: 50%;
      border: 1.5px solid var(--accent);
      background: #000;
    }}
    .author-info h4 {{ font-size: 15px; font-weight: 700; color: #fff; margin-bottom: 4px; }}
    .author-info p {{ font-size: 13px; color: var(--text-muted); }}

    .cta-banner {{
      background: linear-gradient(180deg, #18181F 0%, #0A0A0D 100%);
      border: 1.5px solid var(--border);
      border-radius: 20px;
      padding: 36px 28px;
      text-align: center;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 18px;
      margin-top: 40px;
    }}
    .cta-banner h3 {{ font-size: 22px; font-weight: 900; color: #fff; }}
    .cta-banner p {{ font-size: 14.5px; color: var(--text-muted); max-width: 520px; }}
    .btn-row {{ display: flex; gap: 10px; flex-wrap: wrap; justify-content: center; }}
    .btn-dl {{
      padding: 12px 20px;
      border-radius: 12px;
      font-weight: 700;
      font-size: 13.5px;
      text-decoration: none;
      transition: transform 0.15s ease;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }}
    .btn-dl.primary {{ background: #fff; color: #000; }}
    .btn-dl.secondary {{ background: var(--surface-card); color: #fff; border: 1px solid var(--border); }}
    .btn-dl:hover {{ transform: translateY(-2px); }}
  </style>
</head>
<body>
  <div class="article-wrap">
    <a href="/blog/" class="back-link">{back_label}</a>

    <div class="article-header">
      <div class="badge-row">
        <span class="cat-badge mono">{cat}</span>
        <span>•</span>
        <span class="mono">{read_time}</span>
        <span>•</span>
        <span class="mono">{date}</span>
      </div>
      <h1>{title}</h1>
    </div>

    <div class="hero-img-box">
      <img src="{hero}" alt="{title}" />
      <div class="img-caption mono">{hero_cap}</div>
    </div>

    <div class="content-body">
      <!-- Section 1 -->
      <h2>{h2_1}</h2>
      <p>{p1_1}</p>
      <p>{p1_2}</p>

      <div class="inline-img-card">
        <img src="{img1}" alt="{h2_1}" />
        <div class="img-caption mono">{img1_cap}</div>
      </div>

      <!-- Section 2 -->
      <h2>{h2_2}</h2>
      <p>{p2_1}</p>
      <p>{p2_2}</p>

      <div class="inline-img-card">
        <img src="{img2}" alt="{h2_2}" />
        <div class="img-caption mono">{img2_cap}</div>
      </div>

      <!-- Section 3 -->
      <h2>{h2_3}</h2>
      <p>{p3_1}</p>
      <p>{p3_2}</p>

      <div class="inline-img-card">
        <img src="{img3}" alt="{h2_3}" />
        <div class="img-caption mono">{img3_cap}</div>
      </div>
    </div>

    <!-- Author Card -->
    <div class="author-card">
      <img src="../assets/rfcam_icon.png" alt="RfCamera Team" class="author-avatar" />
      <div class="author-info">
        <h4>RfCamera Editorial Team</h4>
        <p>{author_role}</p>
      </div>
    </div>

    <!-- Bottom Download CTA -->
    <div class="cta-banner">
      <h3>{cta_h3}</h3>
      <p>{cta_p}</p>
      <div class="btn-row">
        <a href="https://rfcam.roycorp.xyz/" class="btn-dl primary">Download on App Store</a>
        <a href="https://play.google.com/store/apps/details?id=xyz.roycorp.rfcam" class="btn-dl secondary">Get on Google Play</a>
      </div>
    </div>
  </div>
</body>
</html>
"""

def main():
    os.makedirs('landing/blog', exist_ok=True)
    generated = []
    for a in articles:
        html = render_article_html(a)
        filepath = os.path.join('landing/blog', f"{a['slug']}.html")
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html)
        generated.append(a)
        print(f"Created: {filepath} ({len(html)} bytes)")

    print(f"\nSuccessfully generated {len(generated)} new articles.")

if __name__ == '__main__':
    main()
