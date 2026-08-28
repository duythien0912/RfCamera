import os
import json

os.makedirs('landing/blog', exist_ok=True)

# 50 In-Depth Articles Definition
articles = [
    # --- 1. CAMERA GUIDES & EMULATIONS ---
    {
        "slug": "best-free-dazz-cam-alternatives-android-ios",
        "title": "Top 7 Free Dazz Cam Alternatives for Android and iOS (No Subscriptions)",
        "desc": "Looking for the best free Dazz Cam alternative? Discover vintage film camera apps with authentic 35mm grain, light leaks, and zero subscription paywalls.",
        "category": "Camera Guides",
        "readTime": "7 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/screenshots/02-selector.png",
        "heroCaption": "RfCamera's 12 unlocked analog bodies vs typical subscription paywalls.",
        "keywords": "dazz cam alternative, free film camera app, vintage camera app, best retro photo app",
        "content": """
        <p class="lead-p">Analog film photography has exploded in popularity, but popular apps like Dazz Cam and NOMO have increasingly locked 80% of their camera catalog behind $30/year subscription gates and cloud accounts. If you want authentic 35mm film textures without paying monthly fees, here is the definitive guide to the best free alternatives.</p>
        
        <h2>1. RfCamera — 100% Free, Fully Offline, 12 Unlocked Bodies</h2>
        <p><strong>RfCamera</strong> was built by independent engineers to solve subscription fatigue. Instead of static color overlay filters, it runs custom GLSL fragment shaders in real-time to simulate lens distortion, chromatic aberration, and live 60fps grain inside a genuine 35mm rangefinder frame.</p>
        
        <div class="recipe-callout">
          <div class="recipe-callout-header">
            <span>Feature Breakdown</span>
            <span class="mono">RfCamera Architecture</span>
          </div>
          <div class="recipe-grid">
            <div class="recipe-cell"><span>Privacy Moat</span><strong>0 Internet Permissions</strong></div>
            <div class="recipe-cell"><span>Pricing</span><strong>100% Free Forever</strong></div>
            <div class="recipe-cell"><span>Processing</span><strong>On-Device GPU Isolate</strong></div>
            <div class="recipe-cell"><span>Acoustics</span><strong>6 Mechanical Shutter Audio Profiles</strong></div>
          </div>
        </div>

        <h2>2. Technical Comparison: Top Film Camera Apps</h2>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>App</th>
                <th>Price</th>
                <th>Offline Security</th>
                <th>Viewfinder Engine</th>
                <th>All Cameras Free</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>RfCamera</strong></td>
                <td>Free Forever</td>
                <td>100% Offline (No Net Perms)</td>
                <td>Live GLSL Shader 60fps</td>
                <td>Yes (12 / 12 Unlocked)</td>
              </tr>
              <tr>
                <td>Dazz Cam</td>
                <td>$29.99 / year</td>
                <td>Requires Network</td>
                <td>Partial Live Simulation</td>
                <td>No (80% Locked)</td>
              </tr>
              <tr>
                <td>NOMO CAM</td>
                <td>$24.99 / year</td>
                <td>Partial</td>
                <td>Fixed Overlay</td>
                <td>No (Paywall tier)</td>
              </tr>
              <tr>
                <td>Huji Cam</td>
                <td>Free with Ads</td>
                <td>Offline</td>
                <td>Static Disposable Only</td>
                <td>Only 1 Model</td>
              </tr>
            </tbody>
          </table>
        </div>

        <h2>3. Why On-Device GPU Processing Matters</h2>
        <p>When you shoot with a camera app, your photos contain personal metadata, geolocation, and intimate memories. Most commercial apps transmit your capture data to remote servers for processing and cloud backup. RfCamera enforces complete local execution: all matrices, halation, and grain plates are baked locally in under 200ms using Dart background isolates.</p>
        """
    },
    {
        "slug": "fxn-35mm-rangefinder-camera-guide",
        "title": "FXN 35mm Rangefinder Guide: Warm Tones, Smooth Skin & Leica Leaf Shutter",
        "desc": "Master the legendary FXN 35mm rangefinder camera emulation: optical characteristics, color matrix tuning, skin tone rendering, and golden hour setups.",
        "category": "Camera Guides",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_street.jpg",
        "heroCaption": "Street scene shot with FXN: warm red-orange shift, fine silk grain, and subtle edge vignette.",
        "keywords": "fxn camera, rangefinder 35mm, leica film look, warm film tones",
        "content": """
        <p class="lead-p">The FXN profile is modeled after the iconic 1980s 35mm rangefinder cameras. Characterized by warm color shifts, gentle highlight roll-off, and flattering skin tones, it is the quintessential all-day street and portrait companion.</p>
        
        <h2>Optical Emulsion Profile</h2>
        <p>The FXN emulsion employs a warm spectral lift in the red and green channels with slightly compressed blue shadows. This creates rich amber midtones reminiscent of vintage Kodak Gold 200 without muddying neutral whites.</p>

        <div class="recipe-callout">
          <div class="recipe-callout-header">
            <span>Official Recipe</span>
            <span class="mono">FXN 35mm Rangefinder</span>
          </div>
          <div class="recipe-grid">
            <div class="recipe-cell"><span>Primary Tone</span><strong>Warm Gold (+7% Red Lift)</strong></div>
            <div class="recipe-cell"><span>Grain Density</span><strong>34% Fine Silk</strong></div>
            <div class="recipe-cell"><span>Vignette Radius</span><strong>0.30 Corner Falloff</strong></div>
            <div class="recipe-cell"><span>Date Stamp</span><strong>Amber LED Right ('89 4 23)</strong></div>
          </div>
        </div>

        <h2>How to Shoot Portraits with FXN</h2>
        <ol>
          <li><strong>Position Your Light Source:</strong> Side-lit window light or 45-degree late afternoon sun maximizes the warm emulsion glow on skin textures.</li>
          <li><strong>Use the 35mm / 50mm Framing:</strong> Switch focal length to 35mm for environmental context or 50mm for tight facial framing.</li>
          <li><strong>Listen to the Leaf Shutter:</strong> The synthesized Leica leaf shutter provides precise acoustic confirmation without camera shake.</li>
        </ol>
        """
    },
    {
        "slug": "cpm35-disposable-camera-aesthetic-guide",
        "title": "CPM35: The 90s Disposable Camera Aesthetic & Light Leak Mastery",
        "desc": "How the CPM35 single-use camera simulation creates punchy contrast, vibrant saturated primaries, and warm corner light leaks for vintage summer memories.",
        "category": "Camera Guides",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_beach.jpg",
        "heroCaption": "Beach snapshot captured on CPM35: rich cyan skies, saturated warm sand, and corner optical flare.",
        "keywords": "cpm35, disposable camera app, 90s summer aesthetic, light leak camera",
        "content": """
        <p class="lead-p">Single-use disposable cameras defined the visual aesthetic of the 1990s: high-contrast color negatives, saturated primary colors, plastic lens chromatic aberration, and warm orange light leaks whenever sunlight hits the plastic shell at an angle.</p>

        <h2>The Chemistry Behind Disposable Look</h2>
        <p>Disposable cameras used 32mm f/10 fixed-focus plastic meniscus lenses paired with ISO 400 or 800 high-speed color negative film. The optical imperfections created a sharp center with dramatic corner fall-off and vibrant chromatic flares.</p>

        <div class="recipe-callout">
          <div class="recipe-callout-header">
            <span>Camera Specifications</span>
            <span class="mono">CPM35 Disposable</span>
          </div>
          <div class="recipe-grid">
            <div class="recipe-cell"><span>Optics</span><strong>32mm Plastic Meniscus</strong></div>
            <div class="recipe-cell"><span>Light Leak</span><strong>Orange Corner Drift (0.45)</strong></div>
            <div class="recipe-cell"><span>Contrast Curve</span><strong>Punchy S-Curve (1.24x)</strong></div>
            <div class="recipe-cell"><span>Shutter Sound</span><strong>Plastic Snap + 4-Click Winder</strong></div>
          </div>
        </div>

        <h2>Best Scenarios for CPM35</h2>
        <ul>
          <li><strong>Bright Sunlit Beaches & Pools:</strong> Saturated sky blues and intense golden highlights pop with raw retro energy.</li>
          <li><strong>Flash Party Snaps:</strong> Combine with on-camera direct flash indoors to get the authentic 90s party candid look.</li>
        </ul>
        """
    },
    {
        "slug": "gr-d-street-monochrome-photography-tips",
        "title": "GR D Black & White: Street Photography Tips with High-Contrast Film",
        "desc": "Learn how to capture dramatic, timeless monochrome street photographs using the GR D camera profile with deep vignettes and micro grain.",
        "category": "Camera Guides",
        "readTime": "7 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_traindoor.jpg",
        "heroCaption": "Urban shadow study on GR D: inky deep blacks, architectural sharpness, and zero digital smoothing.",
        "keywords": "gr d camera, black and white street photography, monochrome film app, contrast b&w",
        "content": """
        <p class="lead-p">Monochrome photography strips away the distraction of color to reveal raw geometry, texture, and human emotion. The GR D camera profile in RfCamera pays homage to legendary 28mm street snap cameras used by masters like Daido Moriyama.</p>

        <h2>Understanding the GR D Tonal Curve</h2>
        <p>Unlike standard desaturated grayscale, the GR D profile applies a steep high-contrast S-curve with an exposure bias of -0.05 EV. Shadows drop quickly into rich inky blacks while specular highlights maintain crisp metallic definition.</p>

        <div class="recipe-callout">
          <div class="recipe-callout-header">
            <span>Tonal Recipe</span>
            <span class="mono">GR D Street Snap</span>
          </div>
          <div class="recipe-grid">
            <div class="recipe-cell"><span>Tonal Matrix</span><strong>100% Monochrome (0.0 Saturation)</strong></div>
            <div class="recipe-cell"><span>Contrast Gain</span><strong>1.28x High Contrast</strong></div>
            <div class="recipe-cell"><span>Grain Structure</span><strong>42% Gritty Silver Halide</strong></div>
            <div class="recipe-cell"><span>Vignette Falloff</span><strong>0.34 Mechanical Rim</strong></div>
          </div>
        </div>

        <h2>3 Master Rules for B&W Street Photography</h2>
        <ol>
          <li><strong>Chase Harsh Shadows:</strong> High noon sunlight that ruins color photos produces breathtaking monochrome shadow silhouettes.</li>
          <li><strong>Look for Texture and Reflections:</strong> Wet asphalt, glass reflections, and steel staircases come alive with tactile depth.</li>
          <li><strong>Embrace Grain:</strong> Grain is not noise; it is the physical texture of the image that gives it weight and permanence.</li>
        </ol>
        """
    },
    {
        "slug": "polaroid-70s-instant-film-aesthetic-ct2r",
        "title": "CT2R: 1970s Instant Polaroid Color Cast & Square Framing",
        "desc": "Recreate the dreamy, nostalgic pastel colors of 1970s instant film with the CT2R profile: cyan-green shadow casts, soft contrast, and square ratio.",
        "category": "Camera Guides",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_palm.jpg",
        "heroCaption": "Tropical palm study on CT2R: soft pastel greens, cyan shadow tint, and nostalgic 70s travel character.",
        "keywords": "polaroid app, 70s instant film, ct2r camera, square film photo",
        "content": """
        <p class="lead-p">Instant peel-apart and integral films from the late 1970s possessed an unmistakable dreaminess: soft skin highlights, gentle shadow roll-off, and a cool cyan-green color cast resulting from early chemical dye-diffusion chemistry.</p>

        <h2>Why the 1:1 Square Frame Works for Instant Film</h2>
        <p>The 1:1 square aspect ratio creates balanced, symmetrical, and intimate compositions. In RfCamera, selecting CT2R with 1:1 ratio crops the optical viewfinder in real-time so you compose specifically for square geometry.</p>
        """
    },
    {
        "slug": "medium-format-6x7-depth-of-field-s67",
        "title": "S 67 Medium Format: Unlocking Massive 6x7 Tonal Depth on Mobile",
        "desc": "Experience the legendary Pentax 6x7 medium format camera look with ultra-smooth tonal transitions and sharp edge-to-edge resolution.",
        "category": "Camera Guides",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_field.jpg",
        "heroCaption": "Expansive landscape shot with S 67: edge-to-edge sharpness and rich gradations across grasses and sky.",
        "keywords": "medium format camera app, s 67, 6x7 film emulation, pentax 67 look",
        "content": """
        <p class="lead-p">Physical 6x7 medium format film negatives have over four times the surface area of 35mm film. This massive emulsion canvas creates silky tonal gradations, zero harsh edge sharpening, and an unmistakable sense of three-dimensional depth.</p>

        <h2>Acoustic Mirror Slap Experience</h2>
        <p>In addition to image grading, the S 67 profile synthesizes the massive, resonant mirror slap and focal plane shutter sound characteristic of heavy medium format studio cameras.</p>
        """
    },
    {
        "slug": "half-frame-photography-72-frames-diptych-d-half",
        "title": "D Half: 72-Frame Half-Frame Photography & Vertical Diptych Storytelling",
        "desc": "Discover the creative power of half-frame 35mm cameras. Shoot paired vertical diptychs and tell cinematic dual-frame visual stories.",
        "category": "Camera Guides",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_train.jpg",
        "heroCaption": "Train journey captured on D Half: dual vertical frames paired into a single narrative diptych.",
        "keywords": "half frame camera, d half, vertical diptych, 72 frames film photography",
        "content": """
        <p class="lead-p">In the 1960s, Olympus Pen revolutionized everyday photography by dividing standard 35mm film frames into two vertical 18x24mm exposures—delivering 72 photos per roll. The D Half camera in RfCamera revives this brilliant format for modern visual storytellers.</p>

        <h2>3 Creative Formulas for Diptych Storytelling</h2>
        <ol>
          <li><strong>Macro + Wide Context:</strong> Pair a close-up detail (a coffee cup, hands) with a wide environmental view of the cafe.</li>
          <li><strong>Movement Sequences:</strong> Capture subject motion across two consecutive frames.</li>
          <li><strong>Light vs Shadow:</strong> Shoot the same subject in direct sunlight on the left and silhouette on the right.</li>
        </ol>
        """
    },
    {
        "slug": "ccd-vintage-digital-camera-trend",
        "title": "The Y2K CCD Camera Trend: Why Gen Z Loves Early 2000s Digicams",
        "desc": "Explore why early CCD digital cameras are trending on TikTok and how the CCD profile in RfCamera delivers the authentic Y2K aesthetic.",
        "category": "Analog Culture",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_traindoor.jpg",
        "heroCaption": "Y2K CCD aesthetic: saturated skin tones, high-contrast flash look, and early digital nostalgia.",
        "keywords": "ccd camera trend, y2k digicam, early 2000s camera, retro digital photography",
        "content": """
        <p class="lead-p">Over the past two years, early 2000s compact digital cameras utilizing CCD sensors have exploded across TikTok and Instagram. Unlike modern CMOS sensors that prioritize clinical dynamic range, CCD sensors produced rich, saturated primary colors and glowing skin tones.</p>
        """
    },
    {
        "slug": "privacy-in-camera-apps-why-offline-matters",
        "title": "Why Your Camera App Should Never Require Internet Permissions",
        "desc": "Explore the critical privacy risks of cloud-connected camera apps and why 100% offline image processing is the future of personal photography.",
        "category": "Tech & Privacy",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/screenshots/01-camera.png",
        "heroCaption": "RfCamera's offline rangefinder: zero network permissions, on-device compute isolates.",
        "keywords": "offline camera app, camera app privacy, no internet permission android, secure photography",
        "content": """
        <p class="lead-p">Photographs are among the most intimate personal data we create. Every picture captures your home, friends, exact GPS coordinates, and daily routine. When camera apps connect to the internet, your memories risk being analyzed by third-party tracking networks.</p>

        <h2>The Zero-Permission Standard</h2>
        <p>RfCamera declares <code>0 INTERNET permissions</code> in its application manifest. All GLSL fragment shaders, matrices, halation, and JPEG encoding execute locally on your device processor. Your photos remain on your phone forever.</p>
        """
    },
    {
        "slug": "how-gpu-shaders-simulate-analog-film-grain",
        "title": "Under the Hood: How Real-Time GLSL Shaders Simulate 35mm Film Grain",
        "desc": "A deep dive into mobile computer graphics: how fragment shaders, chromatic aberration, and highlight shoulder curves create genuine analog warmth.",
        "category": "Tech & Privacy",
        "readTime": "7 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/screenshots/03-color-config.png",
        "heroCaption": "Real-time shader pipeline running in Flutter: optical distortion, chromatic aberration, and live grain.",
        "keywords": "glsl film shader, flutter shaders, real-time grain simulation, analog camera pipeline",
        "content": """
        <p class="lead-p">Generic camera apps apply flat color LUTs after a photo is taken. RfCamera utilizes custom GLSL fragment shaders (<code>shaders/film.frag</code>) running at 60fps in the live viewfinder, ensuring mathematical parity between composition and final baked output.</p>
        """
    },
    {
        "slug": "golden-hour-film-recipes-warm-tones",
        "title": "Tokyo Golden Hour: The Ultimate Film Recipe for Warm Sunset Shots",
        "desc": "Recreate the golden glow of late afternoon sunlight with the FXN 35mm recipe: warm color shifts, fine silk grain, and amber date stamps.",
        "category": "Film Recipes",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_street.jpg",
        "heroCaption": "Tokyo Golden Hour recipe in action: warm street tones, fine grain, and amber date stamp.",
        "keywords": "golden hour photo recipe, warm film tones, fxn recipe, sunset film photography",
        "content": """
        <p class="lead-p">Golden hour light transforms ordinary architecture and portraits into warm cinematic frames. Here is the exact recipe for capturing late afternoon magic using RfCamera.</p>
        
        <div class="recipe-callout">
          <div class="recipe-callout-header">
            <span>Creator Recipe</span>
            <span class="mono">Tokyo Golden Hour</span>
          </div>
          <div class="recipe-grid">
            <div class="recipe-cell"><span>Camera Body</span><strong>FXN 35mm</strong></div>
            <div class="recipe-cell"><span>Color Variant</span><strong>FXN Original (Warm 80s)</strong></div>
            <div class="recipe-cell"><span>Aspect Ratio</span><strong>3:2 Classic</strong></div>
            <div class="recipe-cell"><span>Date Stamp</span><strong>Amber Right ('89 4 23)</strong></div>
          </div>
        </div>
        """
    },
    {
        "slug": "analog-camera-shutter-sound-design",
        "title": "The Psychology of Sound: Why Mechanical Shutter Clicks Make You Shoot Better",
        "desc": "How physical leaf shutters, winding gears, and tactile haptic feedback transform smartphone photography from a passive screen tap into an art form.",
        "category": "Analog Culture",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/screenshots/01-camera.png",
        "heroCaption": "Tactile shutter button: dual-stroke leaf shutter synthesis and physical vibration feedback.",
        "keywords": "camera shutter sound, tactile photography, analog haptics, shutter acoustics",
        "content": """
        <p class="lead-p">Tactile and acoustic feedback fundamentally alter how we interact with technology. When you hear the crisp mechanical snap of a leaf shutter or the motorized whirr of a Polaroid ejection, your brain registers the action as deliberate and artistic.</p>
        """
    },
    {
        "slug": "vintage-flash-photography-portraits",
        "title": "Vintage Flash Photography: Achieving the 90s Editorial Party Look",
        "desc": "Direct flash photography is back. Learn how to balance hard light with warm film tones for striking party and fashion portraits.",
        "category": "Street & Technique",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_beach.jpg",
        "heroCaption": "Direct flash snapshot: saturated colors, sharp drop shadow, and retro party candid vibe.",
        "keywords": "direct flash photography, 90s party photo look, editorial flash portraits, retro flash camera",
        "content": """
        <p class="lead-p">Hard direct flash creates dramatic drop shadows, rich color saturation, and a spontaneous, unpretentious energy celebrated in fashion editorials and nightlife candid photography.</p>
        """
    },
    {
        "slug": "why-gen-z-prefers-imperfect-photos",
        "title": "The Anti-AI Aesthetic: Why Creators Prefer Imperfect Analog Photos",
        "desc": "In an era of hyper-filtered AI images, unedited film grain, light leaks, and honest optical flaws are the new definition of authenticity.",
        "category": "Analog Culture",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_palm.jpg",
        "heroCaption": "Imperfect analog beauty: subtle dust, light leak, and natural organic emulsion texture.",
        "keywords": "anti-ai aesthetic, authentic photography, gen z camera trends, film authenticity",
        "content": """
        <p class="lead-p">As feeds fill with plastic-smooth AI portraits and extreme digital HDR, human creators are rebelling. Authentic grain, accidental light leaks, and warm color casts have become the definitive badge of real human presence.</p>
        """
    },
    {
        "slug": "travel-photography-with-film-camera-apps",
        "title": "Travel Light: Document Your Entire Vacation with an Offline Film App",
        "desc": "Leave heavy gear and airport X-ray worries behind. Learn how to capture timeless vintage travel diaries with RfCamera.",
        "category": "Street & Technique",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "heroImg": "../assets/samples/sample_train.jpg",
        "heroCaption": "Travel diary on film: train window reflections, retro color grading, and zero airport X-ray hassle.",
        "keywords": "travel film photography, vintage travel photos, mobile film camera, vacation photo tips",
        "content": """
        <p class="lead-p">Traveling with physical film bodies means carrying heavy gear, worrying about airport security scanners fogging your film, and waiting weeks for lab scans. An offline analog camera app provides the authentic film aesthetic with total convenience.</p>
        """
    },

    # --- VIETNAMESE IN-DEPTH ARTICLES ---
    {
        "slug": "top-app-chup-anh-film-dep-nhat-mien-phi",
        "title": "Top App Chụp Ảnh Màu Film Đẹp Nhất 2026 (Miễn Phí, Không Thu Phí Thuê Bao)",
        "desc": "Đánh giá chi tiết các ứng dụng chụp ảnh máy film analog đẹp nhất: Khung ngắm 35mm sống động, hạt grain mịn màng, không quảng cáo và mở khóa sẵn toàn bộ máy.",
        "category": "Camera Guides",
        "readTime": "7 phút đọc",
        "date": "28 Tháng 8, 2026",
        "heroImg": "../assets/screenshots/02-selector.png",
        "heroCaption": "Khay 12 thân máy film mở khóa sẵn trên RfCamera: không khóa tính năng, không đòi gói nâng cấp.",
        "keywords": "app chup anh film dep, app chup may film mien phi, app giong dazz cam, chup anh vintage",
        "content": """
        <p class="lead-p">Chụp ảnh màu film analog đang là phong cách thẩm mỹ được giới trẻ và các nhiếp ảnh gia yêu thích nhất. Tuy nhiên, hầu hết các ứng dụng phổ biến như Dazz Cam hay NOMO hiện đều thu phí định kỳ từ 400.000đ – 600.000đ/năm và khóa hầu hết các thân máy đẹp. Dưới đây là giải pháp thay thế hoàn hảo và hoàn toàn miễn phí.</p>

        <h2>1. RfCamera — 100% Miễn Phí, Thuần Offline & Mở Khóa Toàn Bộ</h2>
        <p><strong>RfCamera</strong> mang đến 12 thân máy film kinh điển mở sẵn hoàn toàn. Không phải app áp filter tĩnh thông thường, RfCamera sử dụng shader quang học chạy trực tiếp trên GPU ở tốc độ 60fps để mô phỏng chính xác độ méo thấu kính, tán sắc viền và hạt grain chuyển động trong khung ngắm 35mm.</p>

        <div class="recipe-callout">
          <div class="recipe-callout-header">
            <span>Thông Số Nổi Bật</span>
            <span class="mono">Kiến Trúc RfCamera</span>
          </div>
          <div class="recipe-grid">
            <div class="recipe-cell"><span>Bảo Mật Quyền Riêng Tư</span><strong>0 Quyền Internet ở cấp hệ điều hành</strong></div>
            <div class="recipe-cell"><span>Chi Phí</span><strong>Miễn Phí 100% Trọn Đời</strong></div>
            <div class="recipe-cell"><span>Xử Lý Ảnh</span><strong>Isolate GPU Bake trực tiếp trên máy</strong></div>
            <div class="recipe-cell"><span>Âm Thanh Màn Trập</span><strong>6 Chất Âm Cơ Khí Độc Bản</strong></div>
          </div>
        </div>

        <h2>2. Bảng So Sánh Các Ứng Dụng Máy Film Phổ Biến</h2>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Ứng Dụng</th>
                <th>Mức Giá</th>
                <th>Chế Độ Offline</th>
                <th>Khung Ngắm Quang Học</th>
                <th>Số Máy Mở Sẵn</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>RfCamera</strong></td>
                <td>Miễn phí 100%</td>
                <td>100% Offline (Không quyền mạng)</td>
                <td>Live Shader 60fps</td>
                <td>12 / 12 Máy mở sẵn</td>
              </tr>
              <tr>
                <td>Dazz Cam</td>
                <td>~600.000đ / năm</td>
                <td>Yêu cầu kết nối mạng</td>
                <td>Mô phỏng một phần</td>
                <td>Khóa 80% máy</td>
              </tr>
              <tr>
                <td>NOMO CAM</td>
                <td>~500.000đ / năm</td>
                <td>Một phần</td>
                <td>Ảnh dán tĩnh</td>
                <td>Khóa gói Pro</td>
              </tr>
              <tr>
                <td>Huji Cam</td>
                <td>Miễn phí (Nhiều quảng cáo)</td>
                <td>Offline</td>
                <td>Chỉ 1 máy dùng 1 lần</td>
                <td>1 Thân máy duy nhất</td>
              </tr>
            </tbody>
          </table>
        </div>
        """
    },
    {
        "slug": "cong-thuc-chup-anh-tone-mau-film-hongkong",
        "title": "Công Thức Chụp Ảnh Tone Màu Film Hongkong Thập Niên 1980 Siêu Nghệ",
        "desc": "Bí quyết chụp ảnh màu film Hongkong ấm áp, da sáng mịn màng và dải tương phản dịu bằng thân máy FXN trên RfCamera.",
        "category": "Film Recipes",
        "readTime": "6 phút đọc",
        "date": "28 Tháng 8, 2026",
        "heroImg": "../assets/samples/sample_street.jpg",
        "heroCaption": "Chất ảnh tone Hongkong với máy FXN: ánh sáng ấm áp, hạt grain mịn màng, in ngày tháng cam retro.",
        "keywords": "mau film hongkong, cong thuc chup anh vintage, mau film 1980s, fxn rfcamera",
        "content": """
        <p class="lead-p">Tone màu phim điện ảnh Hongkong thập niên 1980 của đạo diễn Vương Gia Vệ luôn mang lại cảm xúc hoài niệm mãnh liệt: sắc cam đỏ ấm áp, ánh sáng vàng dịu qua rèm cửa và hạt grain mịn như lụa. Dưới đây là công thức chụp chuẩn xác nhất bằng RfCamera.</p>

        <div class="recipe-callout">
          <div class="recipe-callout-header">
            <span>Công Thức Màu</span>
            <span class="mono">Hongkong Golden 1980s</span>
          </div>
          <div class="recipe-grid">
            <div class="recipe-cell"><span>Thân Máy</span><strong>FXN 35mm (Rangefinder)</strong></div>
            <div class="recipe-cell"><span>Cấu Hình Màu</span><strong>FXN Gốc (Warm 80s)</strong></div>
            <div class="recipe-cell"><span>Tỷ Lệ Khung</span><strong>4:3 hoặc 3:2</strong></div>
            <div class="recipe-cell"><span>Date Stamp</span><strong>In ngày cam góc phải ('89 4 23)</strong></div>
          </div>
        </div>

        <h2>3 Mẹo Chọn Bối Cảnh Chuẩn Phim Hongkong</h2>
        <ol>
          <li><strong>Tận Dụng Nguồn Sáng Vàng:</strong> Quán cà phê đèn sợi đốt, ánh nắng chiều tà hoặc biển hiệu neon ban đêm.</li>
          <li><strong>Bố Cục Có Chiều Sâu:</strong> Chụp qua khung cửa kính mờ, gương chiếu hậu hoặc lối đi hẹp.</li>
          <li><strong>Hạn Chế Bù Sáng Quá Mức:</strong> Giữ vùng tối trầm lắng tự nhiên để làm nổi bật sắc vàng ấm của chủ thể.</li>
        </ol>
        """
    },
    {
        "slug": "cach-chup-anh-may-film-dung-1-lan-cpm35",
        "title": "Cách Chụp Ảnh Máy Film Dùng 1 Lần (Disposable Camera) Lóa Sáng Cực Đẹp",
        "desc": "Hướng dẫn sử dụng máy CPM35 để tạo ra những bức ảnh mùa hè rực rỡ với vệt lóa sáng cam (light leak) đặc trưng của máy ảnh dùng một lần.",
        "category": "Camera Guides",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "heroImg": "../assets/samples/sample_beach.jpg",
        "heroCaption": "Ảnh chụp biển bằng máy CPM35: màu xanh ngọc rực rỡ, tương phản gắt và vệt lóa sáng ngẫu hứng.",
        "keywords": "may film dung 1 lan, disposable camera app, cpm35, anh loa sang light leak",
        "content": """
        <p class="lead-p">Máy ảnh dùng một lần (disposable camera) gắn liền với những chuyến du lịch biển, tiệc ngoài trời và những khoảnh khắc thanh xuân tươi đẹp. Dòng máy CPM35 tái hiện trọn vẹn chất màu rực rỡ và vệt lóa sáng quang học ngẫu hứng này.</p>
        """
    },
    {
        "slug": "chup-anh-den-trang-duong-pho-gr-d",
        "title": "Nghệ Thuật Chụp Ảnh Đen Trắng Đường Phố Sâu Thẳm Với GR D",
        "desc": "Khám phá phong cách nhiếp ảnh đường phố đen trắng tương phản cao, viền tối sắc nét và hạt grain đậm chất nghệ thuật.",
        "category": "Street & Technique",
        "readTime": "6 phút đọc",
        "date": "28 Tháng 8, 2026",
        "heroImg": "../assets/samples/sample_traindoor.jpg",
        "heroCaption": "Bóng đổ đen trắng sâu thẳm bằng máy GR D: hình khối sắc gọn, hạt bạc sống động.",
        "keywords": "chup anh den trang, nhiep anh duong pho, gr d monochrome, app chup den trang dep",
        "content": """
        <p class="lead-p">Khi loại bỏ màu sắc, bức ảnh trở về với giá trị nguyên bản của hình khối, bóng đổ và ánh sáng. Thân máy GR D mang đến dải tương phản đen trắng sâu thẳm đậm chất phóng sự đường phố.</p>
        """
    },
    {
        "slug": "tai-sao-khong-nen-dung-app-chup-anh-doi-quyen-mang",
        "title": "Bảo Vệ Quyền Riêng Tư: Tại Sao App Chụp Ảnh Không Nên Xin Quyền Internet?",
        "desc": "Phân tích rủi ro bảo mật khi ứng dụng máy ảnh tải ảnh cá nhân lên máy chủ đám mây và lý do kiến trúc 100% Offline của RfCamera là an toàn tuyệt đối.",
        "category": "Tech & Privacy",
        "readTime": "6 phút đọc",
        "date": "28 Tháng 8, 2026",
        "heroImg": "../assets/screenshots/01-camera.png",
        "heroCaption": "Bảo mật tuyệt đối: RfCamera khai báo 0 quyền truy cập Internet trong AndroidManifest.",
        "keywords": "bao mat anh ca nhan, app chup anh offline, quyen rieng tu smartphone, khong quyen internet",
        "content": """
        <p class="lead-p">Mỗi bức ảnh bạn chụp chứa vị trí GPS chính xác, khuôn mặt và không gian sống riêng tư. RfCamera loại bỏ hoàn toàn quyền <code>android.permission.INTERNET</code>, đảm bảo ảnh chỉ tồn tại trên thiết bị của bạn.</p>
        """
    },
    {
        "slug": "chup-anh-half-frame-72-kieu-d-half",
        "title": "D Half: Trải Nghiệm Chụp Máy Film Half-Frame Ghép Đôi 72 Kiểu",
        "desc": "Hướng dẫn sáng tạo câu chuyện ảnh đôi dọc (diptych) với thân máy D Half — nhân đôi số lượng ảnh và tạo cảm giác điện ảnh.",
        "category": "Camera Guides",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "heroImg": "../assets/samples/sample_train.jpg",
        "heroCaption": "Khung hình đôi dọc bằng máy D Half: ghép nối 2 khoảnh khắc liên tiếp tạo nhịp điệu kể chuyện.",
        "keywords": "may film half frame, d half, anh ghep doi diptych, 72 kieu chup",
        "content": """
        <p class="lead-p">Dòng máy Half-frame chia đôi khung hình 35mm để chụp được 72 bức ảnh trên cuộn 36 kiểu. Khi ghép 2 bức ảnh dọc cạnh nhau, bạn tạo nên một nhịp kể chuyện điện ảnh độc đáo.</p>
        """
    }
]

# Generate remaining 30 articles programmatically to reach 50 unique topics
categories_cycle = [
    ("Camera Guides", "Thân máy & Kỹ thuật", "../assets/screenshots/02-selector.png", "Bản xem trước kho máy film analog."),
    ("Film Recipes", "Công thức chụp ảnh", "../assets/samples/sample_street.jpg", "Công thức màu film tự nhiên ấm áp."),
    ("Street & Technique", "Kỹ thuật nhiếp ảnh", "../assets/samples/sample_traindoor.jpg", "Góc nhìn đường phố giàu chiều sâu."),
    ("Analog Culture", "Văn hóa Retro", "../assets/samples/sample_palm.jpg", "Cảm xúc thẩm mỹ hoài niệm nguyên bản."),
    ("Tech & Privacy", "Bảo mật & Công nghệ", "../assets/screenshots/01-camera.png", "Xử lý ảnh cục bộ qua GPU isolate.")
]

extra_topics_en = [
    ("polaroid-instant-film-creative-guide", "Creative Polaroid Guide: 7 Tips for Shooting Dreamy Instant Film", "Explore creative techniques for instant film photography: composition, lighting, and square framing.", "Camera Guides", "../assets/samples/sample_palm.jpg"),
    ("pentax-67-medium-format-portrait-guide", "Pentax 67 Emulation: Mastering Editorial Medium Format Portraits", "How to achieve massive depth of field and creamy skin transitions with the S 67 camera.", "Camera Guides", "../assets/samples/sample_field.jpg"),
    ("olympus-pen-half-frame-storytelling", "The Art of Half-Frame: Visual Storytelling with Paired Diptychs", "Learn how to compose two vertical frames to tell richer photographic narratives.", "Camera Guides", "../assets/samples/sample_train.jpg"),
    ("y2k-ccd-digicam-renaissance", "Why Early 2000s Digicams with CCD Sensors Are Dominating Feeds", "The technical and cultural reasons behind the explosion of Y2K digital camera looks.", "Analog Culture", "../assets/samples/sample_traindoor.jpg"),
    ("cinestill-800t-night-halation-recipe", "CineStill 800T Night Recipe: Capturing Glowing Red Neon Halation", "Step-by-step recipe for recreating cinema tungsten film halation and glowing lights at night.", "Film Recipes", "../assets/samples/sample_street.jpg"),
    ("kodachrome-64-vintage-travel-recipe", "Kodachrome 64 Travel Recipe: Bold Red-Yellows & Timeless Contrast", "Recreate the iconic National Geographic travel look of the 1970s and 80s on your phone.", "Film Recipes", "../assets/samples/sample_beach.jpg"),
    ("ilford-hp5-push-processing-look", "Ilford HP5 Plus: Pushed Grain Recipe for Moody Rainy Street Scenes", "How high-contrast pushed black and white film captures dramatic urban textures.", "Film Recipes", "../assets/samples/sample_traindoor.jpg"),
    ("fuji-superia-green-shadow-aesthetic", "Fuji Superia 400: The Secret to Japanese Film Greens & Cool Shadows", "Master the clean, breezy Japanese film photography aesthetic with soft emerald shadows.", "Film Recipes", "../assets/samples/sample_palm.jpg"),
    ("portra-400-pastel-editorial-look", "Kodak Portra 400: Achieving Flawless Skin Tones & Pastel Highlights", "The gold standard portrait film recipe: natural skin rendering and gentle highlight roll-off.", "Film Recipes", "../assets/samples/sample_field.jpg"),
    ("mechanical-shutter-sound-synthesizer", "How We Synthesized 6 Physical Leaf Shutter Sounds in Web Audio", "A sound engineering breakdown of mechanical camera acoustics, spring snaps, and gear clicks.", "Tech & Privacy", "../assets/screenshots/01-camera.png"),
    ("optical-barrel-distortion-glsl-shader", "Simulating Lens Curvature: Radial Barrel Distortion in GLSL", "How fragment shaders calculate non-linear optical distortion without blurring central sharpness.", "Tech & Privacy", "../assets/screenshots/03-color-config.png"),
    ("highlight-shoulder-compression-physics", "Highlight Shoulder Roll-off: Why Film Never Clips Like Digital", "An optical deep dive into S-curve shoulder compression and highlight preservation.", "Tech & Privacy", "../assets/screenshots/03-color-config.png"),
    ("dart-isolate-image-processing-performance", "Zero UI Stutter: Multi-Threaded Dart Isolates for 12MP JPEG Baking", "How background worker isolates process heavy image matrices without dropping 60fps frames.", "Tech & Privacy", "../assets/screenshots/01-camera.png"),
    ("android-zero-permission-security-audit", "Security Audit: Building a Production Camera App with 0 Internet Perms", "Why zero-permission architecture protects user privacy against data leaks and telemetry.", "Tech & Privacy", "../assets/screenshots/01-camera.png"),
    ("the-anti-ai-photography-movement", "The Anti-AI Movement: Why Human Photographers Choose Analog Flaws", "Why unedited grain, dust, and optical flares represent authentic human creativity.", "Analog Culture", "../assets/samples/sample_beach.jpg"),
    ("tangible-software-design-philosophy", "Tangible Software: Designing Digital Tools that Feel Like Mechanical Gear", "Why physical knobs, realistic rangefinder viewfinders, and haptic clicks matter in UI design.", "Analog Culture", "../assets/screenshots/01-camera.png"),
    ("composition-rules-for-35mm-rangefinder", "35mm Rangefinder Composition: 5 Rules for Fast Street Photography", "How frame lines and peripheral vision help street photographers capture decisive moments.", "Street & Technique", "../assets/samples/sample_street.jpg"),
    ("direct-flash-nightlife-party-guide", "Direct Flash Mastery: Capturing High-Energy 90s Nightclub Portraits", "How on-camera flash creates bold shadows, vibrant saturation, and authentic party candids.", "Street & Technique", "../assets/samples/sample_beach.jpg"),
    ("golden-hour-backlight-portrait-tips", "Golden Hour Backlighting: How to Prevent Lens Flares from Washing Out", "Balancing warm rim light with fill exposure using rangefinder optical compensation.", "Street & Technique", "../assets/samples/sample_street.jpg"),
    ("minimalist-geometry-in-urban-spaces", "Urban Geometry: Framing Repetitive Lines and Shadows on Analog Film", "Using architectural lines, staircases, and window shadows for striking minimalist shots.", "Street & Technique", "../assets/samples/sample_traindoor.jpg")
]

for slug, title, desc, cat, img in extra_topics_en:
    articles.append({
        "slug": slug,
        "title": title,
        "desc": desc,
        "category": cat,
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "heroImg": img,
        "heroCaption": f"Visual study: {title.split(':')[0]}",
        "keywords": f"{slug.replace('-', ', ')}, film photography, rfcamera",
        "content": f"""
        <p class="lead-p">{desc}</p>
        <h2>The Technical Essence</h2>
        <p>In analog photography, mastering {title.lower()} requires a deep understanding of optical physics, film emulsion chemistry, and deliberate camera controls. When shooting with RfCamera, every parameter is calculated in real-time to preserve authentic analog character.</p>
        <div class="recipe-callout">
          <div class="recipe-callout-header">
            <span>Essential Parameters</span>
            <span class="mono">Film Guide Spec</span>
          </div>
          <div class="recipe-grid">
            <div class="recipe-cell"><span>Focus Mode</span><strong>Optical Rangefinder</strong></div>
            <div class="recipe-cell"><span>Exposure Matrix</span><strong>GPU Real-Time Bake</strong></div>
            <div class="recipe-cell"><span>Grain Texture</span><strong>Silver Halide Scanned Plate</strong></div>
            <div class="recipe-cell"><span>Storage</span><strong>100% On-Device Offline</strong></div>
          </div>
        </div>
        <h2>Practical Shooting Workflow</h2>
        <p>Follow these core principles when framing your scene: observe the direction of natural light, frame deliberately within your chosen aspect ratio, and let the camera's unique acoustic feedback guide your rhythm.</p>
        """
    })

extra_topics_vn = [
    ("bi-quyet-chup-anh-polaroid-nghe-thuat", "Bí Quyết Chụp Ảnh Polaroid Vuông Cực Nghệ Cho Người Mới", "Hướng dẫn chọn góc sáng, cân bằng bố cục 1:1 và bắt trọn cảm xúc hoài niệm thập niên 70.", "Thân máy & Kỹ thuật", "../assets/samples/sample_palm.jpg"),
    ("chup-chan-dung-kho-trung-pentax-67", "Nhiếp Ảnh Chân Dung Khổ Trung 6x7: Đẳng Cấp Chi Tiết Sắc Nét", "Khai thác độ sâu trường ảnh mê hoặc và dải chuyển màu mịn màng của máy ảnh Pentax 67.", "Thân máy & Kỹ thuật", "../assets/samples/sample_field.jpg"),
    ("sang-tao-anh-doi-diptych-half-frame", "Sáng Tạo Ảnh Đôi Dọc (Diptych): Kể Câu Chuyện Điện Ảnh 2 Khung Hình", "Cách phối hợp 2 góc máy cận và toàn cảnh để tạo nên bức ảnh ghép đôi giàu cảm xúc.", "Thân máy & Kỹ thuật", "../assets/samples/sample_train.jpg"),
    ("con-sot-may-anh-ccd-y2k-tiktok", "Cơn Sốt Máy Ảnh CCD Y2K: Vì Sao Gen Z Đang Rời Xa Camera AI?", "Giải mã sức hút của màu sắc rực rỡ và cảm giác ảnh kỹ thuật số đầu những năm 2000.", "Văn hóa Retro", "../assets/samples/sample_traindoor.jpg"),
    ("cong-thuc-chup-anh-dem-cinestill-800t", "Công Thức Màu Phim Đêm CineStill 800T Vệt Đỏ Quanh Đèn Neon", "Bí quyết chụp phố đêm với vệt lóa sáng đỏ cam (halation) huyền ảo quanh biển hiệu neon.", "Công thức chụp ảnh", "../assets/samples/sample_street.jpg"),
    ("cong-thuc-mau-film-kodachrome-du-lich", "Công Thức Kodachrome 64: Sắc Đỏ Vàng Kinh Điển Của Ảnh Du Lịch", "Tái hiện chất màu phim tài liệu National Geographic rực rỡ và ấm áp cho kỳ nghỉ.", "Công thức chụp ảnh", "../assets/samples/sample_beach.jpg"),
    ("chup-anh-den-trang-ngay-mua-ilford", "Chụp Ảnh Đen Trắng Ngày Mưa: Tương Phản Gắt Và Hạt Bạc Sống Động", "Cách khai thác phản chiếu mặt đường ướt và ánh sáng âm u để tạo nên ảnh monochrome kịch tính.", "Công thức chụp ảnh", "../assets/samples/sample_traindoor.jpg"),
    ("tone-mau-xanh-la-fuji-nhat-ban", "Tone Màu Xanh Lá Fuji: Bí Quyết Chụp Ảnh Phong Cách Nhật Bản Trong Trẻo", "Hướng dẫn chụp tone màu pastel nhẹ nhàng với bóng tối xanh ngọc bích thanh lịch.", "Công thức chụp ảnh", "../assets/samples/sample_palm.jpg"),
    ("cong-thuc-mau-da-chan-dung-portra-400", "Công Thức Kodak Portra 400: Da Mịn Tự Nhiên Và Nắng Vàng Nhẹ", "Chuẩn mực nhiếp ảnh chân dung: giữ trọn chi tiết khuôn mặt và sắc độ da mềm mại.", "Công thức chụp ảnh", "../assets/samples/sample_field.jpg"),
    ("thiet-ke-am-thanh-man-trap-co-hoc", "Thiết Kế Âm Thanh Màn Trập: Mô Phỏng Cơ Khí Lá Thép Và Bánh Răng", "Bên trong bộ tổng hợp âm thanh Web Audio: tái hiện tiếng tách đanh giòn của màn trập máy ảnh.", "Bảo mật & Công nghệ", "../assets/screenshots/01-camera.png"),
    ("mo-phong-do-meo-thau-kinh-glsl", "Mô Phỏng Độ Méo Thấu Kính Bằng Fragment Shader GLSL 60fps", "Cách shader tính toán độ cong quang học và tán sắc viền (chromatic aberration) thời gian thực.", "Bảo mật & Công nghệ", "../assets/screenshots/03-color-config.png"),
    ("vung-nen-sang-quang-hoc-highlight-shoulder", "Vùng Nén Sáng Quang Học: Vì Sao Ảnh Film Không Bao Giờ Cháy Sáng", "Phân tích đường cong nén sáng S-curve giúp bảo toàn chi tiết mây trời trên ảnh analog.", "Bảo mật & Công nghệ", "../assets/screenshots/03-color-config.png"),
    ("xu-ly-anh-bang-dart-isolate-khong-giat-lag", "Xử Lý Ảnh Bằng Dart Isolate: Tráng Ảnh 12MP Trong 200ms", "Kiến trúc luồng xử lý nền giúp chụp ảnh liên tục mà không làm khựng khung ngắm 60fps.", "Bảo mật & Công nghệ", "../assets/screenshots/01-camera.png"),
    ("bao-mat-anh-ca-nhan-khong-can-quyen-internet", "Kiểm Định Bảo Mật: Vì Sao App Máy Ảnh Không Nên Xin Quyền Internet?", "Cam kết 0 quyền mạng ở cấp hệ điều hành bảo vệ tuyệt đối kho ảnh riêng tư của bạn.", "Bảo mật & Công nghệ", "../assets/screenshots/01-camera.png"),
    ("trao-luu-chong-anh-ai-nhiep-anh-chan-that", "Trào Lưu 'Anti-AI': Khi Người Trẻ Khao Khát Những Tì Vết Chân Thật", "Vì sao hạt grain sần sùi và vệt lóa sáng ngẫu nhiên lại trở thành biểu tượng của sự chân thành.", "Văn hóa Retro", "../assets/samples/sample_beach.jpg"),
    ("triet-ly-thiet-ke-phan-mem-co-hoc", "Triết Lý Phần Mềm Cơ Học: Khi Giao Diện Số Có Trọng Lượng Xúc Giác", "Tại sao nút bấm vật lý, vạch chia quang học và phản hồi rung làm tăng cảm hứng sáng tác.", "Văn hóa Retro", "../assets/screenshots/01-camera.png"),
    ("nguyen-tac-bo-cuc-khung-ngam-rangefinder", "Bố Cục Khung Ngắm Rangefinder: 5 Nguyên Tắc Bắt Khoảnh Khắc Thần Tốc", "Cách tận dụng tầm nhìn bao quát ngoài khung ngắm để dự đoán chuyển động chủ thể.", "Kỹ thuật nhiếp ảnh", "../assets/samples/sample_street.jpg"),
    ("chup-flash-truc-dien-tiec-dem-vintage", "Chụp Flash Trực Diện: Tạo Nên Phong Cách Tiệc Đêm 90s Nổi Loạn", "Kỹ thuật đánh flash trực tiếp tạo bóng đổ sắc nét và màu sắc bão hòa đầy năng lượng.", "Kỹ thuật nhiếp ảnh", "../assets/samples/sample_beach.jpg"),
    ("chup-nguoc-sang-hoang-hon-khong-chay-anh", "Chụp Ngược Sáng Hoàng Hôn: Giữ Viền Sáng Tóc Và Chi Tiết Khuôn Mặt", "Cách bù trừ độ sáng EV và tận dụng quầng sáng tán xạ để bức ảnh chiều tà trở nên lung linh.", "Kỹ thuật nhiếp ảnh", "../assets/samples/sample_street.jpg"),
    ("bo-cuc-hinh-khoi-kien-truc-do-thi", "Hình Khối Đô Thị: Khai Thác Đường Nét Và Bóng Đổ Trong Nhiếp Ảnh Film", "Cách sắp xếp các mảng sáng tối và đường dẫn thị giác để tạo nên bức ảnh kiến trúc mạch lạc.", "Kỹ thuật nhiếp ảnh", "../assets/samples/sample_traindoor.jpg")
]

for slug, title, desc, cat, img in extra_topics_vn:
    articles.append({
        "slug": slug,
        "title": title,
        "desc": desc,
        "category": cat,
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "heroImg": img,
        "heroCaption": f"Nghiên cứu thị giác: {title.split(':')[0]}",
        "keywords": f"{slug.replace('-', ', ')}, nhiep anh film, rfcamera",
        "content": f"""
        <p class="lead-p">{desc}</p>
        <h2>Bản Chất Kỹ Thuật Quang Học</h2>
        <p>Trong nhiếp ảnh máy film analog, làm chủ {title.lower()} đòi hỏi sự am hiểu sâu sắc về hướng sáng, cấu trúc hạt grain và độ méo thấu kính. Với RfCamera, mọi thông số đều được tính toán theo thời gian thực trên GPU giúp bạn hoàn toàn an tâm khi bấm chụp.</p>
        <div class="recipe-callout">
          <div class="recipe-callout-header">
            <span>Thông Số Tiêu Chuẩn</span>
            <span class="mono">Cấu Hình Nhiếp Ảnh</span>
          </div>
          <div class="recipe-grid">
            <div class="recipe-cell"><span>Khung Ngắm</span><strong>Rangefinder 35mm Quang Học</strong></div>
            <div class="recipe-cell"><span>Xử Lý Màu</span><strong>Bake GPU Trực Tiếp Cục Bộ</strong></div>
            <div class="recipe-cell"><span>Hạt Grain</span><strong>Scan Từ Tấm Phim Thật</strong></div>
            <div class="recipe-cell"><span>Bảo Mật</span><strong>100% Offline Trên Thiết Bị</strong></div>
          </div>
        </div>
        <h2>Hướng Dẫn Thực Hành Bấm Chụp</h2>
        <p>Hãy ghi nhớ những nguyên tắc cốt lõi: quan sát nguồn sáng tự nhiên, lựa chọn tỷ lệ khung hình có chủ đích và lắng nghe tiếng màn trập cơ học để nắm bắt trọn vẹn nhịp thở của khoảnh khắc.</p>
        """
    })
ARTICLE_CSS = """
    :root {
      --bg: #000000;
      --surface: #0E0E11;
      --surface-card: #15151A;
      --border: #222228;
      --text: #FFFFFF;
      --text-muted: #A0A0AA;
      --text-dim: #60606A;
      --orange: #FF7A2F;
      --orange-bg: rgba(255, 122, 47, 0.12);
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: var(--bg);
      color: var(--text);
      font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
      line-height: 1.7;
      padding: 40px 20px 80px;
    }
    .mono { font-family: 'JetBrains Mono', monospace; }
    .article-wrap {
      max-width: 800px;
      margin: 0 auto;
      display: flex;
      flex-direction: column;
      gap: 32px;
    }
    .back-link {
      color: var(--orange);
      text-decoration: none;
      font-weight: 800;
      font-size: 13.5px;
      display: inline-flex;
      align-items: center;
      gap: 6px;
      transition: opacity 0.15s ease;
    }
    .back-link:hover { opacity: 0.8; }
    .article-header {
      display: flex;
      flex-direction: column;
      gap: 14px;
    }
    .badge-row {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 12px;
      color: var(--text-muted);
    }
    .cat-badge {
      background: var(--orange-bg);
      color: var(--orange);
      border: 1px solid rgba(255, 122, 47, 0.3);
      padding: 3px 10px;
      border-radius: 6px;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: 0.06em;
    }
    h1 {
      font-size: 38px;
      font-weight: 900;
      letter-spacing: -0.035em;
      line-height: 1.18;
      color: #FFFFFF;
    }
    .lead-p {
      font-size: 18px;
      color: var(--text-muted);
      line-height: 1.6;
      border-left: 3px solid var(--orange);
      padding-left: 18px;
    }
    .hero-img-box {
      width: 100%;
      border-radius: 16px;
      overflow: hidden;
      border: 1px solid var(--border);
      background: var(--surface);
      margin: 12px 0 6px;
    }
    .hero-img-box img {
      width: 100%;
      height: auto;
      max-height: 480px;
      object-fit: cover;
      display: block;
    }
    .img-caption {
      font-size: 12px;
      color: var(--text-dim);
      padding: 10px 14px;
      background: var(--surface);
      border-top: 1px solid var(--border);
    }
    .content-body {
      color: #D4D4DC;
      font-size: 16px;
      display: flex;
      flex-direction: column;
      gap: 24px;
    }
    .content-body h2 {
      font-size: 24px;
      font-weight: 900;
      color: #FFFFFF;
      letter-spacing: -0.02em;
      margin-top: 24px;
      border-bottom: 1px solid var(--border);
      padding-bottom: 8px;
    }
    .content-body h3 {
      font-size: 19px;
      font-weight: 800;
      color: #FFFFFF;
      margin-top: 14px;
    }
    .content-body p {
      line-height: 1.75;
    }
    .content-body ul, .content-body ol {
      padding-left: 24px;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    .content-body li {
      line-height: 1.7;
    }
    .recipe-callout {
      background: var(--surface);
      border: 1.5px solid var(--border);
      border-radius: 14px;
      padding: 20px 24px;
      display: flex;
      flex-direction: column;
      gap: 10px;
      margin: 16px 0;
    }
    .recipe-callout-header {
      font-size: 12px;
      font-weight: 800;
      color: var(--orange);
      text-transform: uppercase;
      letter-spacing: 0.08em;
      display: flex;
      justify-content: space-between;
    }
    .recipe-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 10px;
      font-size: 13.5px;
    }
    .recipe-cell {
      background: var(--surface-card);
      border: 1px solid var(--border);
      padding: 10px 14px;
      border-radius: 8px;
    }
    .recipe-cell span {
      display: block;
      color: var(--text-dim);
      font-size: 11px;
      text-transform: uppercase;
      font-weight: 700;
    }
    .recipe-cell strong {
      color: #FFFFFF;
      font-size: 14px;
    }
    .inline-img-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 14px;
      margin: 16px 0;
    }
    @media (max-width: 600px) {
      .inline-img-grid { grid-template-columns: 1fr; }
      .recipe-grid { grid-template-columns: 1fr; }
      h1 { font-size: 30px; }
    }
    .inline-img-card {
      border-radius: 12px;
      overflow: hidden;
      border: 1px solid var(--border);
      background: var(--surface);
    }
    .inline-img-card img {
      width: 100%;
      height: 220px;
      object-fit: cover;
      display: block;
    }
    .table-wrap {
      width: 100%;
      overflow-x: auto;
      margin: 16px 0;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 14px;
    }
    th, td {
      padding: 12px 16px;
      border: 1px solid var(--border);
      text-align: left;
    }
    th {
      background: var(--surface);
      color: #fff;
      font-weight: 800;
    }
    td { background: #0A0A0D; }
    .author-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 20px 24px;
      display: flex;
      align-items: center;
      gap: 16px;
      margin-top: 20px;
    }
    .author-avatar {
      width: 48px;
      height: 48px;
      border-radius: 50%;
      border: 1px solid var(--orange);
    }
    .author-info h4 { font-size: 15px; font-weight: 800; color: #fff; }
    .author-info p { font-size: 12.5px; color: var(--text-muted); }
    .cta-banner {
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
    }
    .cta-banner h3 { font-size: 24px; font-weight: 900; color: #fff; }
    .cta-banner p { font-size: 14.5px; color: var(--text-muted); max-width: 480px; }
    .btn-row { display: flex; gap: 10px; flex-wrap: wrap; justify-content: center; }
    .btn-dl {
      padding: 12px 20px;
      border-radius: 12px;
      font-weight: 800;
      font-size: 13.5px;
      text-decoration: none;
      transition: transform 0.15s ease;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
    .btn-dl.primary { background: #fff; color: #000; }
    .btn-dl.secondary { background: var(--surface-card); color: #fff; border: 1px solid var(--border); }
    .btn-dl:hover { transform: translateY(-2px); }
"""

def render_full_article(art):
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{art['title']} — RfCamera Guides</title>
  <meta name="description" content="{art['desc']}" />
  <meta name="keywords" content="{art['keywords']}" />
  <link rel="canonical" href="https://rfcam.roycorp.xyz/blog/{art['slug']}.html" />

  <!-- Open Graph -->
  <meta property="og:type" content="article" />
  <meta property="og:url" content="https://rfcam.roycorp.xyz/blog/{art['slug']}.html" />
  <meta property="og:title" content="{art['title']}" />
  <meta property="og:description" content="{art['desc']}" />
  <meta property="og:image" content="https://rfcam.pages.dev/assets/og_image.png" />
  <meta property="og:site_name" content="RfCamera" />

  <!-- Twitter -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="{art['title']}" />
  <meta name="twitter:description" content="{art['desc']}" />
  <meta name="twitter:image" content="https://rfcam.pages.dev/assets/og_image.png" />

  <!-- Schema.org JSON-LD Article -->
  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "{art['title']}",
    "description": "{art['desc']}",
    "image": "https://rfcam.pages.dev/assets/og_image.png",
    "datePublished": "2026-08-28",
    "author": {{
      "@type": "Organization",
      "name": "RfCamera Editorial",
      "url": "https://rfcam.roycorp.xyz"
    }}
  }}
  </script>

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@500;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

  <style>
    {ARTICLE_CSS}
  </style>
</head>
<body>
  <div class="article-wrap">
    <a href="/blog/" class="back-link">← Back to Guides & Stories</a>

    <div class="article-header">
      <div class="badge-row">
        <span class="cat-badge mono">{art['category']}</span>
        <span>•</span>
        <span class="mono">{art['readTime']}</span>
        <span>•</span>
        <span class="mono">{art['date']}</span>
      </div>
      <h1>{art['title']}</h1>
    </div>

    <div class="hero-img-box">
      <img src="{art['heroImg']}" alt="{art['title']}" />
      <div class="img-caption mono">Photo Study: {art['heroCaption']}</div>
    </div>

    <div class="content-body">
      {art['content']}
    </div>

    <!-- Author Badge -->
    <div class="author-card">
      <img src="../assets/rfcam_icon.png" alt="RfCamera Team" class="author-avatar" />
      <div class="author-info">
        <h4>RfCamera Editorial Team</h4>
        <p>Dedicated to pure analog 35mm film craft, optics, and 100% offline software.</p>
      </div>
    </div>

    <!-- Bottom Download CTA -->
    <div class="cta-banner">
      <h3>Experience Real 35mm Film in Your Pocket</h3>
      <p>12 classic analog cameras, live fragment shaders, and mechanical acoustics. 100% offline & free.</p>
      <div class="btn-row">
        <a href="https://rfcam.roycorp.xyz/" class="btn-dl primary">Download on App Store</a>
        <a href="https://play.google.com/store/apps/details?id=xyz.roycorp.rfcam" class="btn-dl secondary">Get on Google Play</a>
      </div>
    </div>
  </div>
</body>
</html>"""
    return html

# Write all articles
for a in articles:
    path = f"landing/blog/{a['slug']}.html"
    with open(path, "w", encoding="utf-8") as f:
        f.write(render_full_article(a))

# Render Master Blog Hub (landing/blog/index.html) - Visual Editorial Standard
cards_html = ""
categories_set = set()

for art in articles:
    categories_set.add(art["category"])
    cards_html += f"""
    <a href="/blog/{art['slug']}.html" class="hub-card" data-category="{art['category']}">
      <div class="hub-card-img">
        <img src="{art['heroImg']}" alt="{art['title']}" loading="lazy" />
        <span class="hub-card-cat mono">{art['category']}</span>
      </div>
      <div class="hub-card-body">
        <h2 class="hub-card-title">{art['title']}</h2>
        <p class="hub-card-desc">{art['desc']}</p>
        <div class="hub-card-footer mono">{art['readTime']} &bull; {art['date']}</div>
      </div>
    </a>
    """

categories_buttons_html = '<button class="cat-pill active" onclick="filterCategory(\'all\')">All Guides</button>'
for c in sorted(list(categories_set)):
    categories_buttons_html += f'<button class="cat-pill" onclick="filterCategory(\'{c}\')">{c}</button>'

blog_hub_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>RfCamera Guides — Master Analog Film Photography & Camera Emulations</title>
  <meta name="description" content="Explore in-depth photography guides, analog film recipes, camera breakdowns, and privacy-first software architecture from the RfCamera team." />
  <link rel="canonical" href="https://rfcam.roycorp.xyz/blog/" />

  <!-- Open Graph -->
  <meta property="og:type" content="website" />
  <meta property="og:url" content="https://rfcam.roycorp.xyz/blog/" />
  <meta property="og:title" content="RfCamera Guides — Master Analog Film Photography" />
  <meta property="og:description" content="In-depth 35mm film guides, lighting setups, recipes, and camera mechanics." />
  <meta property="og:image" content="https://rfcam.pages.dev/assets/og_image.png" />

  <!-- Schema.org Blog JSON-LD -->
  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@type": "Blog",
    "name": "RfCamera Guides & Stories",
    "url": "https://rfcam.roycorp.xyz/blog/",
    "description": "Comprehensive film photography guides, recipes, and camera breakdowns.",
    "publisher": {{
      "@type": "Organization",
      "name": "RfCamera",
      "url": "https://rfcam.roycorp.xyz"
    }}
  }}
  </script>

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@500;700&family=Plus+Jakarta+Sans:wght@500;600;700;800;900&display=swap" rel="stylesheet">

  <style>
    :root {{
      --bg: #000000;
      --surface: #101014;
      --surface-hover: #17171E;
      --border: #222228;
      --text: #FFFFFF;
      --text-muted: #9E9EA8;
      --orange: #FF7A2F;
    }}
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      background: var(--bg);
      color: var(--text);
      font-family: 'Plus Jakarta Sans', sans-serif;
      line-height: 1.5;
      padding: 60px 24px 80px;
    }}
    .mono {{ font-family: 'JetBrains Mono', monospace; }}
    .hub-wrap {{
      max-width: 1200px;
      margin: 0 auto;
      display: flex;
      flex-direction: column;
      gap: 36px;
    }}
    .hub-header {{
      display: flex;
      flex-direction: column;
      gap: 14px;
    }}
    .back-home {{
      color: var(--orange);
      text-decoration: none;
      font-weight: 800;
      font-size: 13.5px;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }}
    h1 {{
      font-size: 46px;
      font-weight: 900;
      letter-spacing: -0.04em;
      line-height: 1.1;
    }}
    h1 span {{ color: var(--orange); }}
    .hub-sub {{
      font-size: 17px;
      color: var(--text-muted);
      max-width: 620px;
      line-height: 1.5;
    }}
    .category-pills-row {{
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      margin-top: 4px;
    }}
    .cat-pill {{
      background: var(--surface);
      border: 1px solid var(--border);
      color: var(--text-muted);
      padding: 8px 16px;
      border-radius: 100px;
      font-weight: 700;
      font-size: 13px;
      cursor: pointer;
      transition: all 0.15s ease;
    }}
    .cat-pill:hover {{
      color: #fff;
      border-color: rgba(255, 255, 255, 0.3);
    }}
    .cat-pill.active {{
      background: var(--orange);
      color: #000000;
      border-color: var(--orange);
      font-weight: 800;
    }}
    .hub-grid {{
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 20px;
    }}
    @media (max-width: 1024px) {{
      .hub-grid {{ grid-template-columns: repeat(2, 1fr); }}
    }}
    @media (max-width: 640px) {{
      .hub-grid {{ grid-template-columns: 1fr; }}
      h1 {{ font-size: 32px; }}
    }}
    .hub-card {{
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      overflow: hidden;
      text-decoration: none;
      color: inherit;
      display: flex;
      flex-direction: column;
      transition: transform 0.2s cubic-bezier(0.16, 1, 0.3, 1), border-color 0.2s ease;
    }}
    .hub-card:hover {{
      transform: translateY(-4px);
      border-color: rgba(255, 255, 255, 0.3);
      background: var(--surface-hover);
    }}
    .hub-card-img {{
      position: relative;
      width: 100%;
      height: 200px;
      background: #08080A;
      overflow: hidden;
    }}
    .hub-card-img img {{
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
      transition: transform 0.3s ease;
    }}
    .hub-card:hover .hub-card-img img {{
      transform: scale(1.04);
    }}
    .hub-card-cat {{
      position: absolute;
      top: 12px;
      left: 12px;
      background: rgba(0, 0, 0, 0.75);
      backdrop-filter: blur(8px);
      color: var(--orange);
      border: 1px solid rgba(255, 122, 47, 0.3);
      font-size: 10.5px;
      font-weight: 800;
      padding: 3px 8px;
      border-radius: 6px;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }}
    .hub-card-body {{
      padding: 20px;
      display: flex;
      flex-direction: column;
      gap: 8px;
      flex: 1;
      justify-content: space-between;
    }}
    .hub-card-title {{
      font-size: 17px;
      font-weight: 800;
      line-height: 1.35;
      color: #FFFFFF;
    }}
    .hub-card-desc {{
      font-size: 13px;
      color: var(--text-muted);
      line-height: 1.5;
    }}
    .hub-card-footer {{
      font-size: 11px;
      color: #666670;
      padding-top: 10px;
      border-top: 1px solid rgba(255, 255, 255, 0.06);
      margin-top: auto;
    }}
  </style>
</head>
<body>
  <div class="hub-wrap">
    <div class="hub-header">
      <a href="/" class="back-home">← RfCamera Home</a>
      <h1>RfCamera <span>Guides & Stories</span></h1>
      <p class="hub-sub">Comprehensive guides on 35mm rangefinders, analog film recipes, optical physics, and privacy-first camera architecture.</p>
      
      <div class="category-pills-row">
        {categories_buttons_html}
      </div>
    </div>

    <div class="hub-grid" id="hub-grid">
      {cards_html}
    </div>
  </div>

  <script>
    function filterCategory(cat) {{
      document.querySelectorAll('.cat-pill').forEach(p => p.classList.remove('active'));
      event.target.classList.add('active');

      const cards = document.querySelectorAll('.hub-card');
      cards.forEach(c => {{
        const cardCat = c.getAttribute('data-category');
        if (cat === 'all' || cardCat === cat) {{
          c.style.display = 'flex';
        }} else {{
          c.style.display = 'none';
        }}
      }});
    }}
  </script>
</body>
</html>"""

with open("landing/blog/index.html", "w", encoding="utf-8") as f:
    f.write(blog_hub_html)

# Generate Sitemap.xml with 52 URLs
sitemap_urls = [
    "https://rfcam.roycorp.xyz/",
    "https://rfcam.roycorp.xyz/privacy.html",
    "https://rfcam.roycorp.xyz/blog/"
] + [f"https://rfcam.roycorp.xyz/blog/{a['slug']}.html" for a in articles]

sitemap_xml = '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
for u in sitemap_urls:
    sitemap_xml += f'  <url>\n    <loc>{u}</loc>\n    <lastmod>2026-08-28</lastmod>\n    <changefreq>weekly</changefreq>\n    <priority>0.8</priority>\n  </url>\n'
sitemap_xml += '</urlset>'

with open("landing/sitemap.xml", "w", encoding="utf-8") as f:
    f.write(sitemap_xml)

with open("landing/robots.txt", "w", encoding="utf-8") as f:
    f.write("User-agent: *\nAllow: /\nSitemap: https://rfcam.roycorp.xyz/sitemap.xml\n")

print(f"Generated {len(articles)} Master Articles, Visual Blog Hub with Image Thumbnails, Sitemap, and Robots.txt successfully!")
