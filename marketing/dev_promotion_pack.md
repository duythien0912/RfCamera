# RfCamera — Developer Promotion & Launch Pack

Bộ tài liệu truyền thông chân thật, xuất phát từ góc nhìn của lập trình viên xây dựng sản phẩm (Builder/Engineer Perspective). Không dùng văn mẫu PR, tập trung vào giải quyết vấn đề thực tế: **Máy film analog trung thực, 100% Offline, không xin quyền mạng, không thu phí.**

---

## 1. Show HN (Hacker News)

**Title:** Show HN: RfCamera – An offline, zero-permission 35mm film camera app written in Flutter

**Post Content:**

```markdown
Hey HN,

I built RfCamera because I was tired of film camera apps charging $30/year subscriptions while secretly requiring cloud logins and tracking analytics.

Most camera apps today fall into two categories:
1. Gimmicky filter apps that just slap a static LUT over your picture.
2. Premium subscription apps (like Dazz Cam or NOMO) that lock 80% of vintage cameras behind paywalls and upload your data to remote servers.

I wanted something that felt like picking up a real rangefinder from the 80s:
- **Zero Network Permissions**: The app declares NO `android.permission.INTERNET` at the OS level. It runs 100% offline. Photos are saved directly into your device storage.
- **Honest Viewfinder Pipeline**: A single `FilmEffect` configuration drives both the real-time viewfinder (via custom GLSL fragment shaders for barrel distortion, chromatic aberration, and live grain) and the final JPEG baking. What you compose in the frame is mathematically identical to what is exported.
- **Isolate GPU Baking**: When you hit the shutter, the full-res capture is processed in a background Dart `compute()` isolate. No UI frame drops, no freezing.
- **12 Fully Unlocked Camera Models**: Including 35mm Rangefinders (FXN), Disposable Point-and-Shoots (CPM35 with optical light leaks), Street B&W (GR D), 1970s Instant Polaroid (CT2R), Medium Format 6x7 (S 67), and 72-frame Half-Frame (D Half).
- **Physical Acoustics**: Each camera model synthesizes its own physical leaf shutter and motorized film advance acoustics using Web Audio / native audio synthesis.

The app is completely free, with no sign-in, no telemetry, and no in-app purchases.

Landing page & Web Viewfinder Demo: https://rfcam.roycorp.xyz/
Google Play Store: https://play.google.com/store/apps/details?id=xyz.roycorp.rfcam

Would love your feedback on the shader pipeline and camera grain tuning!
```

---

## 2. Reddit r/androidapps & r/photography

**Subreddits:** `r/androidapps`, `r/photography`, `r/analog`, `r/flutterdev`

**Title:** I got tired of $30/year subscriptions for film camera apps, so I built a 100% offline, free 35mm camera app (RfCamera)

**Post Content:**

```markdown
Hi everyone,

Like many of you here, I love the aesthetic of analog film cameras — the imperfect grain, warm halation, light leaks, and the intentional pacing of composing through a 35mm rangefinder.

However, almost every popular film app on the Play Store today has become bloated: mandatory accounts, $3–$5/month subscriptions, ads, and background analytics. Worse, many of them don't even process photos offline.

So I spent the last few months building **RfCamera**:
- **100% Free & Unlocked**: All 12 camera bodies, lenses (Fisheye, Prism, Star filter), and accessories are free. No subscriptions, no paywalls.
- **Zero Tracking / Zero Cloud**: The app literally declares zero internet permissions on Android. Your photos never leave your device.
- **Real Optical Viewfinder**: Live 60fps film grain, highlight roll-off shoulder curve, and optical distortion so you see the actual film look before pressing the shutter.
- **12 Classic Cameras**: 
  - `FXN`: Warm 35mm rangefinder tones with smooth skin reproduction.
  - `CPM35`: Classic 90s disposable camera with corner light leaks and punchy contrast.
  - `GR D`: High-contrast street monochrome with deep vignettes.
  - `CT2R`: 1970s instant film with vintage cyan-green cast.
  - `S 67`: 6x7 medium format with massive depth of field.
  - `D Half`: 72-frame half-frame diptychs.
- **Individual Shutter Sounds**: Every camera model has its own distinct mechanical shutter click and motor advance sound.

You can try the web simulator or grab the app directly:
- Web: https://rfcam.roycorp.xyz/
- Play Store: https://play.google.com/store/apps/details?id=xyz.roycorp.rfcam

Let me know what you think and what classic film stocks/cameras you'd like me to add next!
```

---

## 3. X / Twitter Tech Launch Thread

**Tweet 1 (Hook):**
> I was sick of paying $30/yr subscriptions for film camera apps that upload your photos to remote servers.
> 
> So I built RfCamera: a 100% offline, accountless 35mm camera app with real GLSL shaders, live grain, and 12 classic analog cameras.
> 
> Free forever. Here is how it works under the hood 🧵👇

**Tweet 2 (The Shader Pipeline):**
> Most apps slap a cheap LUT overlay after you take the photo.
> 
> RfCamera uses a unified `FilmEffect` pipeline. A custom GLSL shader (`film.frag`) runs live in the viewfinder, computing barrel distortion, chromatic aberration, and highlight shoulder compression at 60fps.
> 
> What you see in the frame is what lands on disk.

**Tweet 3 (Zero Permissions & Privacy):**
> Privacy is a feature, not a setting.
> 
> RfCamera declares `0 INTERNET permissions` in its Android manifest.
> 
> No accounts. No phone numbers. No analytics. Photos are processed via background isolates and written strictly to local storage.

**Tweet 4 (12 Iconic Cameras):**
> Every camera has a personality:
> • FXN: Warm 35mm rangefinder
> • CPM35: 90s disposable with light leaks
> • GR D: High-contrast street B&W
> • CT2R: 1977 instant Polaroid
> • S 67: 6x7 medium format
> • D Half: 72-frame half-frame diptychs
> 
> Every single body, lens, and accessory is unlocked.

**Tweet 5 (Physical Acoustics):**
> We even synthesized distinct mechanical shutter acoustics for each camera:
> • Leica leaf shutter snap
> • Disposable plastic ratchet gear winding
> • Electronic micro-leaf transient
> • Polaroid motorized ejection hum
> • Pentax 67 heavy mirror slap

**Tweet 6 (Download / Try Web Demo):**
> Try the interactive 35mm web simulator or install the app:
> 🌐 Web: https://rfcam.roycorp.xyz/
> 📱 Android: https://play.google.com/store/apps/details?id=xyz.roycorp.rfcam
> 
> Retweet to support free, offline software! 📷✨

---

## 4. Diễn Đàn Công Nghệ Việt Nam (Tinh Tế, Voz, J2TEAM)

**Tiêu đề:** [Chia sẻ app] Mình tự code một chiếc app máy ảnh film 35mm thuần Offline, không quảng cáo, mở khóa toàn bộ máy

**Nội dung bài đăng:**

```markdown
Chào anh em,

Mình là một dev mê chụp ảnh film. Dạo gần đây các app chụp ảnh màu film như Dazz Cam hay NOMO trên điện thoại ngày càng đắt đỏ (toàn đòi đăng ký thuê bao 400k - 600k/năm) mà đa số máy đẹp đều bị khóa, chưa kể nhiều app đòi quyền mạng và theo dõi ngầm.

Bức xúc quá nên mình tự ngồi code luôn một app cho anh em mê chất film cổ điển: **RfCamera**.

### Những điểm mình làm kỹ nhất cho app:
1. **Hoàn toàn Offline & Tôn trọng quyền riêng tư**: App không xin quyền INTERNET trong `AndroidManifest.xml`. Không bắt đăng ký tài khoản, không tải ảnh lên bất kỳ server nào. Ảnh chụp xong bake bằng GPU trực tiếp trên máy và lưu vào album của app.
2. **Khung ngắm Rangefinder trung thực**: Viền ngoài tối mờ, bên trong sắc gọn, hạt grain chuyển động theo thời gian thực. Khung ngắm dùng GLSL shader riêng để mô phỏng độ méo quang học và lóa sáng, nhìn sao là ảnh ra y như vậy.
3. **Mở khóa sẵn 12 thân máy film kinh điển**:
   - `FXN`: Tông ấm 35mm da mịn, tương phản dịu.
   - `CPM35`: Máy film dùng 1 lần (disposable) có vệt lóa sáng cam (light leak) góc ảnh.
   - `GR D`: Đen trắng đường phố tương phản cao, tối viền nghệ thuật.
   - `CT2R`: Màu film lấy liền Polaroid thập niên 70.
   - `S 67`: Khổ trung 6x7 chi tiết sắc bén.
   - `D Half`: Half-frame 72 kiểu tự động ghép đôi 2 ảnh dọc.
4. **Âm thanh màn trập cơ học riêng cho từng máy**: Tiếng lá thép Leica đanh sắc, tiếng bánh răng lên film nhựa rẹt rẹt, tiếng mô tơ đẩy ảnh Polaroid... nghe rất sướng tai.
5. **Giao diện tiếng Việt gọn gàng**: Giữ đúng các nút cơ học "Cấu Hình Màu", "Tỷ Lệ 4:3, 1:1, 16:9, 3:2".

App hoàn toàn miễn phí trọn đời, không có paywall hay quảng cáo nào.

Anh em có thể xem thử giao diện trên web hoặc tải app trực tiếp:
- Web: https://rfcam.roycorp.xyz/ (hoặc https://rfcam.pages.dev/)
- Google Play: https://play.google.com/store/apps/details?id=xyz.roycorp.rfcam

Anh em trải nghiệm thử và cho mình xin góp ý để hoàn thiện thêm nhé!
```
