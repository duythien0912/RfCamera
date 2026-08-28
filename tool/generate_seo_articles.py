import os
import json
import re

os.makedirs('landing/blog', exist_ok=True)

# 25 English SEO Articles Definition
en_articles = [
    {
        "slug": "best-free-dazz-cam-alternatives-android-ios",
        "title": "Top 7 Free Dazz Cam Alternatives for Android and iOS (No Subscriptions)",
        "desc": "Looking for the best free Dazz Cam alternative? Discover top vintage film camera apps with authentic 35mm grain, light leaks, and zero subscription paywalls.",
        "category": "App Comparison",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "keywords": "dazz cam alternative, free film camera app, vintage camera app, best retro photo app",
        "content": """
        <p>Analog film photography has experienced a massive resurgence, but popular apps like Dazz Cam have increasingly pushed users into costly annual subscriptions and mandatory cloud accounts. If you want authentic 35mm film textures without recurring fees, here are the best free alternatives available today.</p>
        <h2>1. RfCamera — 100% Free & Fully Offline</h2>
        <p><strong>RfCamera</strong> stands out by offering 12 classic analog film bodies completely unlocked with zero ads and zero subscription paywalls. Unlike typical filter apps, RfCamera uses real-time GLSL fragment shaders to simulate optical barrel distortion, chromatic aberration, and live 60fps grain inside a genuine 35mm rangefinder viewfinder.</p>
        <p>Key highlights of RfCamera include:</p>
        <ul>
            <li><strong>Zero Network Permissions:</strong> The app operates 100% offline, ensuring your private photos never leave your device.</li>
            <li><strong>Authentic Shutter Acoustics:</strong> Every camera model (Leica rangefinders, disposable point-and-shoots, Polaroid instant) features custom synthesized mechanical shutter sounds.</li>
            <li><strong>GPU Isolate Baking:</strong> Full-resolution photos are baked in background isolates without UI stutter.</li>
        </ul>
        <h2>2. Why Subscription-Free Film Apps Matter</h2>
        <p>Many modern camera apps charge $20 to $40 per year simply to unlock digital filters. When choosing a film camera emulator, prioritize apps that process images locally on your GPU rather than uploading your personal images to cloud servers.</p>
        <h2>3. Comparison Table: Best Film Camera Apps</h2>
        <table>
            <thead>
                <tr>
                    <th>App</th>
                    <th>Price</th>
                    <th>Offline Support</th>
                    <th>Unlocked Cameras</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>RfCamera</strong></td>
                    <td>100% Free</td>
                    <td>Yes (0 Network Perms)</td>
                    <td>12 / 12 Unlocked</td>
                </tr>
                <tr>
                    <td>Dazz Cam</td>
                    <td>Freemium ($29.99/yr)</td>
                    <td>Partial</td>
                    <td>Limited in Free tier</td>
                </tr>
                <tr>
                    <td>NOMO CAM</td>
                    <td>Freemium ($24.99/yr)</td>
                    <td>Partial</td>
                    <td>Limited in Free tier</td>
                </tr>
            </tbody>
        </table>
        <h2>Conclusion</h2>
        <p>If you want the true tactile feel of vintage film cameras with honest live viewfinders and zero paywalls, download <a href="https://rfcam.roycorp.xyz/">RfCamera</a> on Android and iOS today.</p>
        """
    },
    {
        "slug": "how-to-get-35mm-film-look-on-smartphone",
        "title": "How to Get the Authentic 35mm Film Look on Any Smartphone",
        "desc": "Master the art of shooting 35mm vintage film photos on your smartphone. Learn lighting techniques, grain simulation, and optical shutter secrets.",
        "category": "Photography Guide",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "35mm film look, smartphone film photography, vintage camera effects, retro photo recipe",
        "content": """
        <p>Modern smartphone cameras produce ultra-sharp, computationally smoothed images that often lack the soul and character of physical 35mm film. Achieving an authentic analog look requires understanding how film emulsion reacts to light, grain, and optical flaws.</p>
        <h2>1. Embrace Highlight Roll-Off and Emulsion Latency</h2>
        <p>Physical film does not clip bright highlights abruptly like digital sensors. Analog emulsion compresses extreme highlights smoothly along an S-shaped shoulder curve. Use an app with optical highlight compression like RfCamera to prevent skies and streetlights from blowing out into harsh white squares.</p>
        <h2>2. Understand Film Grain vs. Digital Noise</h2>
        <p>Digital noise is random, pixelated sensor artifacting. Real film grain consists of microscopic silver halide crystals that have organic depth and texture. To achieve genuine grain, look for apps that use real scanned film grain plates rather than generic noise algorithms.</p>
        <h2>3. Shoot with Intentional Framing</h2>
        <p>Vintage 35mm rangefinders forced photographers to compose carefully within 3:2 and 4:3 optical frame lines. Slow down your shooting pace, look for natural golden hour light, and let the camera's character tell the story.</p>
        """
    },
    {
        "slug": "cpm35-disposable-camera-aesthetic-guide",
        "title": "CPM35: The 90s Disposable Camera Aesthetic Explained",
        "desc": "Discover how the CPM35 single-use camera simulation creates vibrant colors, warm corner light leaks, and punchy 1990s nostalgic photos.",
        "category": "Camera Emulations",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "cpm35, disposable camera app, 90s camera look, light leak effect",
        "content": """
        <p>The disposable camera aesthetic of the 1990s is iconic: high contrast, vibrant saturated yellows and reds, and serendipitous warm corner light leaks. The CPM35 profile in RfCamera meticulously recreates this beloved visual style.</p>
        <h2>Why Disposable Cameras Look So Nostalgic</h2>
        <p>Disposable cameras used simple plastic meniscus lenses and high-speed color negative film (typically ISO 400 or 800). This combination produced sharp center contrast with soft edges, slight chromatic aberration, and warm orange light leaks whenever the plastic body flexed.</p>
        <h2>How to Shoot with CPM35</h2>
        <ul>
            <li><strong>Direct Sunlight:</strong> CPM35 thrives in bright outdoor sunlight, producing punchy blues and warm golden highlights.</li>
            <li><strong>Flash Portraits:</strong> Indoors or at dusk, trigger the flash to get the classic party snapshot look with sharp drop shadows.</li>
        </ul>
        """
    },
    {
        "slug": "gr-d-street-monochrome-photography-tips",
        "title": "GR D Black & White: Street Photography Tips with High-Contrast Film",
        "desc": "Learn how to capture moody, dramatic monochrome street photographs using the GR D camera profile with deep vignettes and fine grain.",
        "category": "Camera Emulations",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "gr d camera, black and white street photography, monochrome film app, contrast b&w",
        "content": """
        <p>Street photography is defined by timing, light, and geometry. The GR D camera emulation in RfCamera strips away the distraction of color, letting you focus entirely on deep shadows, sharp textures, and raw human emotion.</p>
        <h2>Key Characteristics of GR D Monochrome</h2>
        <p>The GR D profile delivers deep, inky blacks, bright architectural highlights, and a subtle mechanical vignette that draws the viewer's eye straight to the center of the frame.</p>
        <h2>3 Tips for Better B&W Street Shots</h2>
        <ol>
            <li><strong>Hunt for Harsh Sunlight:</strong> Strong midday sun creates dramatic architectural shadows and silhouettes.</li>
            <li><strong>Look for Repetitive Geometry:</strong> Zebra crossings, staircases, and window frames pop with punchy monochrome contrast.</li>
            <li><strong>Get Close:</strong> Use the 28mm wide focal length to place the viewer right in the heart of the action.</li>
        </ol>
        """
    },
    {
        "slug": "privacy-in-camera-apps-why-offline-matters",
        "title": "Why Your Camera App Should Never Require Internet Permissions",
        "desc": "Explore the critical privacy risks of cloud-connected camera apps and why 100% offline image processing is the future of personal photography.",
        "category": "Privacy & Tech",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "offline camera app, camera app privacy, no internet permission android, secure photography",
        "content": """
        <p>Every photo you take contains sensitive metadata: exact GPS coordinates, timestamps, facial data, and intimate glimpses into your personal life. When camera apps request internet access, your private memories risk being uploaded, analyzed, or leaked.</p>
        <h2>The Zero-Permission Philosophy</h2>
        <p><strong>RfCamera</strong> declares zero network permissions at the Android OS level (`android.permission.INTERNET` is completely absent). All GPU shaders and JPEG isolate baking occur locally on your phone's processor. Your photos belong to you, on your device, forever.</p>
        """
    },
    {
        "slug": "how-gpu-shaders-simulate-analog-film-grain",
        "title": "Under the Hood: How Real-Time GLSL Shaders Simulate 35mm Film Grain",
        "desc": "A deep dive into mobile computer graphics: how fragment shaders, chromatic aberration, and highlight shoulder curves create genuine analog warmth.",
        "category": "Privacy & Tech",
        "readTime": "7 min read",
        "date": "August 28, 2026",
        "keywords": "glsl film shader, flutter shaders, real-time grain simulation, analog camera pipeline",
        "content": """
        <p>Creating an authentic film camera app is an engineering challenge. Generic filter apps simply multiply RGB values with a static color matrix. To achieve physical realism, RfCamera utilizes custom GLSL fragment shaders compiled natively into the Flutter engine.</p>
        <h2>The Optical Shader Pipeline</h2>
        <p>Inside <code>shaders/film.frag</code>, the shader computes radial barrel distortion and multi-band chromatic aberration in real-time at 60 frames per second. Highlights undergo an S-curve shoulder roll-off before hitting the color matrix, ensuring that skies retain rich cloud structures instead of clipping flat.</p>
        """
    },
    {
        "slug": "polaroid-70s-instant-film-aesthetic-ct2r",
        "title": "CT2R: Capturing the Iconic 1970s Instant Polaroid Color Cast",
        "desc": "Everything you need to know about 1970s instant film aesthetics: nostalgic cyan-green hues, soft contrast, and square ratio framing.",
        "category": "Camera Emulations",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "polaroid app, 70s instant film, ct2r camera, retro instant photo",
        "content": """
        <p>Instant film from the late 1970s possessed a dreamy, ethereal character: pastel highlights, slightly desaturated skin tones, and a signature cool cyan-green color cast in the shadows. The CT2R profile captures this timeless magic.</p>
        <h2>Best Subjects for CT2R</h2>
        <ul>
            <li><strong>Portraits & Candid Moments:</strong> Soft skin tones and gentle contrast flatter faces under natural window light.</li>
            <li><strong>Botanicals & Nature:</strong> Foliage and palms take on a nostalgic vintage travel magazine look.</li>
            <li><strong>Square 1:1 Aspect Ratio:</strong> Pair CT2R with the 1:1 square ratio for authentic Polaroid proportions.</li>
        </ul>
        """
    },
    {
        "slug": "medium-format-6x7-depth-of-field-s67",
        "title": "S 67 Medium Format: Unlocking Massive Depth of Field on Mobile",
        "desc": "Experience the legendary Pentax 6x7 medium format camera look with ultra-smooth tonal transitions and sharp edge-to-edge resolution.",
        "category": "Camera Emulations",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "medium format camera app, s 67, 6x7 film emulation, depth of field retro",
        "content": """
        <p>Medium format 6x7 film is revered by editorial portrait and landscape photographers for its immense negative area, breathtaking tonal gradations, and razor-sharp clarity. The S 67 camera profile brings this legendary format to your pocket.</p>
        <h2>Why Medium Format Looks Distinctive</h2>
        <p>Compared to 35mm, 6x7 negatives have over four times the surface area. This produces buttery smooth shadow transitions, zero harsh digital sharpening, and rich natural color fidelity.</p>
        """
    },
    {
        "slug": "half-frame-photography-72-frames-diptych-d-half",
        "title": "D Half: The Art of 72-Frame Half-Frame Photography & Vertical Diptychs",
        "desc": "Discover the creative power of half-frame 35mm cameras. Shoot paired vertical diptychs and tell cinematic dual-frame visual stories.",
        "category": "Photography Guide",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "half frame camera, d half, vertical diptych, 72 frames film photography",
        "content": """
        <p>In the 1960s, Olympus Pen introduced half-frame photography, allowing photographers to capture two vertical 18x24mm images on a single 35mm film frame—yielding 72 shots per roll. The D Half camera in RfCamera revives this brilliant storytelling format.</p>
        <h2>Creative Ideas for Vertical Diptychs</h2>
        <ol>
            <li><strong>Macro & Wide Pairings:</strong> Capture a wide view of a room paired with an intimate close-up detail.</li>
            <li><strong>Action Sequences:</strong> Shoot two consecutive moments to capture motion, emotion, or reaction.</li>
            <li><strong>Portrait & Environment:</strong> Pair a close portrait with the subject's surrounding landscape.</li>
        </ol>
        """
    },
    {
        "slug": "vintage-camera-aspect-ratios-guide",
        "title": "Optical Aspect Ratios Explained: 4:3, 1:1, 16:9, and 3:2 in Film Photography",
        "desc": "How different framing ratios change the emotional impact of your photography. Learn when to use 3:2 rangefinder, 4:3 classic, or 1:1 square.",
        "category": "Photography Guide",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "aspect ratios photography, 3:2 ratio, 4:3 vs 16:9, film framing guide",
        "content": """
        <p>Framing is the foundation of photographic storytelling. In RfCamera, switching aspect ratios is not a digital post-crop—it dynamically alters your optical viewfinder so you compose with deliberate intent.</p>
        <ul>
            <li><strong>3:2 (35mm Standard):</strong> Perfect for cinematic landscapes and classic street photography.</li>
            <li><strong>4:3 (Classic Medium):</strong> Balanced, versatile, and ideal for portraits.</li>
            <li><strong>1:1 (Square):</strong> Symmetrical, focused, and timeless for minimalist compositions.</li>
            <li><strong>16:9 (Cinematic Wide):</strong> Dramatic wide-angle vistas and modern video frames.</li>
        </ul>
        """
    },
    {
        "slug": "golden-hour-film-recipes-warm-tones",
        "title": "Tokyo Golden Hour: The Ultimate Film Recipe for Warm Sunset Shots",
        "desc": "Recreate the golden glow of late afternoon sunlight with the FXN 35mm recipe: warm color shifts, fine silk grain, and amber date stamps.",
        "category": "Film Recipes",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "golden hour photo recipe, warm film tones, fxn recipe, sunset film photography",
        "content": """
        <p>Golden hour—the hour just before sunset—provides soft, directional, warm light that transforms ordinary scenes into cinematic memories. Here is the exact film recipe to maximize golden hour beauty using RfCamera.</p>
        <h2>The Tokyo Golden Hour Recipe</h2>
        <ul>
            <li><strong>Camera Body:</strong> FXN (Rangefinder 1982)</li>
            <li><strong>Color Profile:</strong> FXN Original (Warm 80s)</li>
            <li><strong>Aspect Ratio:</strong> 3:2 or 4:3</li>
            <li><strong>Grain Setting:</strong> 34% Fine Silk</li>
            <li><strong>Date Stamp:</strong> Orange Right ('89 4 23)</li>
        </ul>
        """
    },
    {
        "slug": "night-street-photography-film-grain",
        "title": "Night Street Photography: Capturing Neon Lights and Gritty Film Grain",
        "desc": "Tips for shooting stunning night photos with film camera apps: handling neon contrast, high ISO grain, and avoiding digital smoothing.",
        "category": "Photography Guide",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "night film photography, neon retro camera, night street photo tips, high iso grain",
        "content": """
        <p>Shooting analog film at night requires embracing deep shadow contrast and high-speed film grain. Use neon signs, wet asphalt reflections, and backlit shop windows to create moody urban nocturnal images.</p>
        """
    },
    {
        "slug": "ccd-vintage-digital-camera-trend",
        "title": "The Y2K CCD Camera Trend: Why Gen Z Loves Early 2000s Digicams",
        "desc": "Explore why early CCD digital cameras are trending on TikTok and how the CCD profile in RfCamera delivers the authentic Y2K aesthetic.",
        "category": "Retro Culture",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "ccd camera trend, y2k digicam, early 2000s camera, retro digital photography",
        "content": """
        <p>Over the past two years, early 2000s digicams with CCD sensors have exploded in popularity among Gen Z creators on TikTok and Instagram. Discover the physics behind CCD color rendering and how to achieve the look on your smartphone.</p>
        """
    },
    {
        "slug": "analog-camera-shutter-sound-design",
        "title": "The Psychology of Sound: Why Mechanical Shutter Clicks Make You Shoot Better",
        "desc": "How physical leaf shutters, winding gears, and tactile haptic feedback transform smartphone photography from a passive screen tap into an art form.",
        "category": "Retro Culture",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "camera shutter sound, tactile photography, analog haptics, shutter acoustics",
        "content": """
        <p>Acoustic feedback is deeply tied to human satisfaction. Hearing the crisp metallic snap of a Leica leaf shutter or the motorized whirr of an instant camera triggers intentionality and mindfulness in photography.</p>
        """
    },
    {
        "slug": "best-film-stocks-emulated-in-rfcamera",
        "title": "Top Film Stocks Emulated in RfCamera: Kodak, Fuji, Ilford & Polaroid",
        "desc": "A comprehensive guide to the classic film stocks simulated in RfCamera, from Kodak Gold 200 warmth to Ilford HP5 black & white drama.",
        "category": "Camera Emulations",
        "readTime": "6 min read",
        "date": "August 28, 2026",
        "keywords": "kodak gold emulation, fuji superia app, ilford hp5 digital, film stock comparison",
        "content": """
        <p>Every roll of physical film has a unique chemical emulsion recipe. Explore how RfCamera's 12 camera models map to history's most celebrated film emulsions.</p>
        """
    },
    {
        "slug": "why-gen-z-prefers-imperfect-photos",
        "title": "The Anti-AI Aesthetic: Why Creators Prefer Imperfect Analog Photos",
        "desc": "In an era of hyper-filtered AI images, unedited film grain, light leaks, and honest optical flaws are the new definition of authenticity.",
        "category": "Retro Culture",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "anti-ai aesthetic, authentic photography, gen z camera trends, film authenticity",
        "content": """
        <p>As social feeds become saturated with synthetic AI images and extreme HDR smoothing, raw optical imperfections—grain, halation, lens flares—have become the hallmark of genuine human creativity.</p>
        """
    },
    {
        "slug": "travel-photography-with-film-camera-apps",
        "title": "Travel Light: How to Document Your Entire Vacation on a 35mm Film App",
        "desc": "Leave heavy camera gear behind. Learn how to capture timeless vintage travel photos using only your smartphone and RfCamera.",
        "category": "Photography Guide",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "travel film photography, vintage travel photos, mobile film camera, vacation photo tips",
        "content": """
        <p>Traveling with bulky film bodies and airport X-ray security concerns can be stressful. Discover how a dedicated offline film app allows you to shoot nostalgic travel diaries effortlessly.</p>
        """
    },
    {
        "slug": "film-camera-vs-filter-apps-comparison",
        "title": "Film Camera Apps vs. Filter Overlay Apps: What's the Difference?",
        "desc": "Why post-processing filter apps fall short compared to real-time optical viewfinders with live grain and exposure simulation.",
        "category": "App Comparison",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "film camera vs filter, live viewfinder app, authentic retro camera, real-time grain",
        "content": """
        <p>Understand the technical and creative distinction between applying a static color filter after shooting versus composing through a living, graded 35mm optical viewfinder.</p>
        """
    },
    {
        "slug": "understanding-halation-and-bloom-in-film",
        "title": "What is Film Halation? The Science of Red Halos Around Bright Lights",
        "desc": "Learn what causes analog film halation, why warm film bases glow red around lights, and how RfCamera simulates real optical scatter.",
        "category": "Photography Guide",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "film halation, red glow highlights, cinestill 800t look, analog bloom",
        "content": """
        <p>When intense light penetrates film layers and reflects off the anti-halation backing, it produces a distinctive red-orange halo around specular highlights. Discover how RfCamera models this physical phenomenon.</p>
        """
    },
    {
        "slug": "how-to-share-film-photos-instagram-tiktok",
        "title": "How to Format and Share Film Photos for Maximum Reach on Instagram & TikTok",
        "desc": "Formatting tips for social media: optimal crop ratios, diptych layouts, and using aesthetic date stamps to boost engagement.",
        "category": "Social & Viral",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "instagram film photo tips, tiktok camera recipes, vintage photo hashtags, diptych stories",
        "content": """
        <p>Maximize your engagement on Threads, Instagram, and TikTok by exporting your analog photos in native 4:5 portrait, 9:16 story, and paired diptych formats.</p>
        """
    },
    {
        "slug": "vintage-flash-photography-portraits",
        "title": "Vintage Flash Photography: Achieving the 90s Editorial Party Look",
        "desc": "Direct flash photography is back. Learn how to balance hard light with warm film tones for striking party and fashion portraits.",
        "category": "Photography Guide",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "direct flash photography, 90s party photo look, editorial flash portraits, retro flash camera",
        "content": """
        <p>Hard direct flash combined with warm film saturation creates an energetic, glamorous, unpretentious aesthetic popular in fashion editorials and nightlife candid photography.</p>
        """
    },
    {
        "slug": "black-and-white-film-recipes-monochrome",
        "title": "3 Black & White Film Recipes for Architecture, Street, and Moody Portraits",
        "desc": "Step-by-step monochrome recipes using the GR D profile: contrast settings, vignette levels, and lighting techniques.",
        "category": "Film Recipes",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "black and white recipes, monochrome film app, street photography recipe, b&w portrait guide",
        "content": """
        <p>Explore three ready-to-use black and white recipes engineered for architectural lines, moody rain street scenes, and expressive dramatic portraits.</p>
        """
    },
    {
        "slug": "minimalist-photography-with-1-1-square-ratio",
        "title": "Square Format Mastery: Minimalist Compositions with 1:1 Aspect Ratio",
        "desc": "How the 1:1 square aspect ratio forces balance, symmetry, and geometric simplicity in vintage photography.",
        "category": "Photography Guide",
        "readTime": "4 min read",
        "date": "August 28, 2026",
        "keywords": "square photography, 1:1 ratio tips, minimalist photo composition, polaroid square guide",
        "content": """
        <p>The square format eliminates horizontal or vertical bias, requiring strict compositional discipline. Learn how to create compelling centered and symmetrical minimalist images.</p>
        """
    },
    {
        "slug": "how-rfcamera-bakes-photos-offline",
        "title": "Offline GPU Architecture: How RfCamera Bakes 12MP JPEGs in 200ms",
        "desc": "A technical breakdown of Dart isolates, multi-threaded image processing, and local storage pipeline in RfCamera.",
        "category": "Privacy & Tech",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "flutter compute isolate, mobile image processing, offline gpu baking, fast camera engine",
        "content": """
        <p>Discover how RfCamera processes complex optical matrices, halation, grain, and date stamps in background CPU/GPU worker threads in under 200 milliseconds without dropping viewfinder frames.</p>
        """
    },
    {
        "slug": "future-of-analog-photography-apps",
        "title": "The Future of Analog Photography Apps: Authenticity, Tactility, and Privacy",
        "desc": "Where retro camera apps are headed: zero-subscription business models, true optical emulation, and respectful local data ownership.",
        "category": "Retro Culture",
        "readTime": "5 min read",
        "date": "August 28, 2026",
        "keywords": "future of photo apps, analog photography trends, ethical app design, retro camera revolution",
        "content": """
        <p>As photographers push back against subscription fatigue and invasive data harvesting, the next generation of creative tools will be defined by uncompromising craft, tactile delight, and absolute user privacy.</p>
        """
    }
]

# 25 Vietnamese SEO Articles Definition
vn_articles = [
    {
        "slug": "top-app-chup-anh-film-dep-nhat-mien-phi",
        "title": "Top 5 App Chụp Ảnh Màu Film Đẹp Nhất 2026 (Miễn Phí, Không Cần Mua Gói)",
        "desc": "Tổng hợp top ứng dụng chụp ảnh film vintage đẹp nhất cho iPhone và Android. Khung ngắm 35mm thật, hạt grain mịn, không quảng cáo và mở khóa toàn bộ máy.",
        "category": "Đánh giá ứng dụng",
        "readTime": "6 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "app chup anh film dep, app chup may film mien phi, app giong dazz cam, chup anh vintage",
        "content": """
        <p>Chụp ảnh màu film cổ điển đang là xu hướng yêu thích của giới trẻ và các nhà sáng tạo nội dung. Tuy nhiên, phần lớn các ứng dụng nổi tiếng hiện nay như Dazz Cam hay NOMO đều bắt đầu thu phí đắt đỏ hoặc khóa hầu hết các thân máy đẹp. Dưới đây là những ứng dụng chụp ảnh film miễn phí và chất lượng nhất hiện nay.</p>
        <h2>1. RfCamera — 100% Miễn Phí & Hoàn Toàn Offline</h2>
        <p><strong>RfCamera</strong> là ứng dụng máy ảnh film analog thuần khiết, mở sẵn toàn bộ 12 thân máy film kinh điển mà không đòi hỏi bất kỳ gói nâng cấp thuê bao nào.</p>
        <p>Những ưu điểm vượt trội của RfCamera:</p>
        <ul>
            <li><strong>Không cần mạng (100% Offline):</strong> Ứng dụng không xin quyền truy cập Internet, bảo mật tuyệt đối ảnh riêng tư của bạn.</li>
            <li><strong>Khung ngắm Rangefinder 35mm thật:</strong> Hạt grain chạy 60fps và độ trễ quang học giúp bạn thấy trước chính xác bức ảnh sẽ ra sao.</li>
            <li><strong>Âm thanh màn trập cơ học độc bản:</strong> Mỗi chiếc máy có tiếng nhả màn trập lá thép Leica, bánh răng nhựa hoặc mô tơ Polaroid riêng.</li>
        </ul>
        <h2>2. So sánh các app chụp ảnh film phổ biến</h2>
        <table>
            <thead>
                <tr>
                    <th>Ứng dụng</th>
                    <th>Giá</th>
                    <th>Chế độ Offline</th>
                    <th>Số máy mở sẵn</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>RfCamera</strong></td>
                    <td>Miễn phí trọn đời</td>
                    <td>100% Offline (0 quyền mạng)</td>
                    <td>12 / 12 Máy mở sẵn</td>
                </tr>
                <tr>
                    <td>Dazz Cam</td>
                    <td>Thuê bao ~600k/năm</td>
                    <td>Một phần</td>
                    <td>Khóa phần lớn máy</td>
                </tr>
                <tr>
                    <td>Huji Cam</td>
                    <td>Miễn phí (Nhiều quảng cáo)</td>
                    <td>Có</td>
                    <td>Chỉ có 1 máy</td>
                </tr>
            </tbody>
        </table>
        """
    },
    {
        "slug": "cong-thuc-chup-anh-tone-mau-film-hongkong",
        "title": "Công Thức Chụp Ảnh Tone Màu Film Hongkong Thập Niên 1980 Siêu Nghệ",
        "desc": "Bí quyết chụp ảnh màu film Hongkong ấm áp, tương phản dịu và da sáng tự nhiên bằng thân máy FXN trên RfCamera.",
        "category": "Công thức chụp ảnh",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "mau film hongkong, cong thuc chup anh vintage, mau film 1980s, fxn rfcamera",
        "content": """
        <p>Tone màu phim điện ảnh Hongkong thập niên 80-90 luôn mang lại cảm xúc hoài niệm mãnh liệt: sắc đỏ cam ấm áp, ánh sáng vàng dịu và hạt grain mịn màng như lụa.</p>
        <h2>Cách thiết lập công thức tone Hongkong</h2>
        <ul>
            <li><strong>Thân máy:</strong> FXN (Rangefinder 1982)</li>
            <li><strong>Cấu hình màu:</strong> FXN Gốc (Warm 80s)</li>
            <li><strong>Tỷ lệ khung:</strong> 4:3 hoặc 3:2</li>
            <li><strong>Bối cảnh lý tưởng:</strong> Quán cà phê đèn vàng, phố đêm có biển hiệu neon, ánh nắng hoàng hôn qua cửa sổ.</li>
        </ul>
        """
    },
    {
        "slug": "cach-chup-anh-may-film-dung-1-lan-cpm35",
        "title": "Cách Chụp Ảnh Máy Film Dùng 1 Lần (Disposable Camera) Lóa Sáng Cực Đẹp",
        "desc": "Hướng dẫn sử dụng máy CPM35 để tạo ra những bức ảnh mùa hè rực rỡ với vệt lóa sáng cam (light leak) đặc trưng của máy ảnh dùng một lần.",
        "category": "Thân máy & Kỹ thuật",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "may film dung 1 lan, disposable camera app, cpm35, anh loa sang light leak",
        "content": """
        <p>Máy ảnh dùng một lần (disposable camera) gắn liền với những chuyến du lịch biển, tiệc ngoài trời và những khoảnh khắc thanh xuân rực rỡ. Dòng máy CPM35 tái hiện hoàn hảo chất nhựa thô mộc và vệt lóa sáng ngẫu hứng này.</p>
        <h2>Mẹo chụp ảnh đẹp với CPM35</h2>
        <ol>
            <li><strong>Tận dụng ánh nắng gắt:</strong> Nắng hè làm nổi bật độ bão hòa màu vàng cam và xanh trời của cuộn phim.</li>
            <li><strong>Chụp góc xiên sáng:</strong> Để nguồn sáng nằm ở góc trên bức ảnh để kích hoạt hiệu ứng light leak cam rực rỡ.</li>
        </ol>
        """
    },
    {
        "slug": "chup-anh-den-trang-duong-pho-gr-d",
        "title": "Nghệ Thuật Chụp Ảnh Đen Trắng Đường Phố Sâu Thẳm Với GR D",
        "desc": "Khám phá phong cách nhiếp ảnh đường phố đen trắng tương phản cao, viền tối sắc nét và hạt grain đậm chất nghệ thuật.",
        "category": "Thân máy & Kỹ thuật",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "chup anh den trang, nhiep anh duong pho, gr d monochrome, app chup den trang dep",
        "content": """
        <p>Khi loại bỏ màu sắc, người xem sẽ tập trung hoàn toàn vào hình khối, ánh sáng, bóng đổ và cảm xúc nhân vật. Thân máy GR D là công cụ đường phố hoàn hảo cho phong cách này.</p>
        """
    },
    {
        "slug": "tai-sao-khong-nen-dung-app-chup-anh-doi-quyen-mang",
        "title": "Bảo Vệ Quyền Riêng Tư: Tại Sao App Chụp Ảnh Không Nên Xin Quyền Internet?",
        "desc": "Phân tích rủi ro bảo mật khi ứng dụng máy ảnh tải ảnh cá nhân lên máy chủ đám mây và lý do kiến trúc 100% Offline của RfCamera là an toàn tuyệt đối.",
        "category": "Bảo mật & Công nghệ",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "bao mat anh ca nhan, app chup anh offline, quyen rieng tu smartphone, khong quyen internet",
        "content": """
        <p>Mỗi bức ảnh bạn chụp chứa vị trí GPS chính xác, khuôn mặt và không gian sống riêng tư. RfCamera loại bỏ hoàn toàn quyền <code>android.permission.INTERNET</code>, đảm bảo ảnh chỉ tồn tại trên thiết bị của bạn.</p>
        """
    },
    {
        "slug": "chup-anh-half-frame-72-kieu-d-half",
        "title": "D Half: Trải Nghiệm Chụp Máy Film Half-Frame Ghép Đôi 72 Kiểu",
        "desc": "Hướng dẫn sáng tạo câu chuyện ảnh đôi dọc (diptych) với thân máy D Half — nhân đôi số lượng ảnh và tạo cảm giác điện ảnh.",
        "category": "Thân máy & Kỹ thuật",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "may film half frame, d half, anh ghep doi diptych, 72 kieu chup",
        "content": """
        <p>Dòng máy Half-frame chia đôi khung hình 35mm để chụp được 72 bức ảnh trên cuộn 36 kiểu. Khi ghép 2 bức ảnh dọc cạnh nhau, bạn tạo nên một nhịp kể chuyện điện ảnh độc đáo.</p>
        """
    },
    {
        "slug": "chat-mau-film-polaroid-thap-nien-70-ct2r",
        "title": "CT2R: Màu Film Lấy Liền Polaroid Thập Niên 70 Tông Xanh Ngọc Hoài Niệm",
        "desc": "Tái hiện cảm giác bấm chụp máy ảnh lấy liền cổ điển với viền ảnh vuông và tông màu pastel dịu mát.",
        "category": "Thân máy & Kỹ thuật",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "mau polaroid vintage, ct2r instant, app chup polaroid, anh mau pastel",
        "content": """
        <p>Màu film lấy liền thập niên 1970 mang sắc độ xanh ngọc nhạt đặc trưng ở vùng tối và màu da mềm mại. Phù hợp cho chân dung ngoài trời và ảnh kỷ niệm bạn bè.</p>
        """
    },
    {
        "slug": "chup-anh-kho-trung-medium-format-s67",
        "title": "S 67 Medium Format: Đẳng Cấp Chi Tiết Sắc Nét Và Độ Sâu Trường Ảnh 6x7",
        "desc": "Trải nghiệm dòng máy Pentax 6x7 đồ sộ trên điện thoại với dải chuyển màu mượt mà tuyệt đối.",
        "category": "Thân máy & Kỹ thuật",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "medium format 6x7, s 67 pentax, do sau truong anh, nhiep anh film chuyen nghiep",
        "content": """
        <p>Khổ phim 6x7 có diện tích gấp hơn 4 lần phim 35mm thông thường, mang đến độ mịn chi tiết và chiều sâu không gian vượt trội cho ảnh phong cảnh và chân dung.</p>
        """
    },
    {
        "slug": "y-nghia-cac-ty-le-khung-hinh-may-film",
        "title": "Ý Nghĩa Các Tỷ Lệ Khung Hình: 4:3, 1:1, 16:9 Và 3:2 Trong Nhiếp Ảnh",
        "desc": "Cách lựa chọn tỷ lệ khung hình phù hợp với từng thể loại ảnh: Chân dung, Phong cảnh, Bố cục đối xứng và Điện ảnh.",
        "category": "Kỹ thuật nhiếp ảnh",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "ty le khung hinh 4:3 3:2 1:1 16:9, bo cuc anh film, cach cat khung anh",
        "content": """
        <p>Khung hình là ranh giới thị giác của bức ảnh. Chọn tỷ lệ đúng ngay trong khung ngắm giúp bạn rèn luyện tư duy bố cục mạch lạc và có chủ đích.</p>
        """
    },
    {
        "slug": "cach-chup-anh-dem-co-hat-grain-vintage",
        "title": "Bí Quyết Chụp Ảnh Đêm Có Hạt Grain Cực Nghệ Không Bị Bệt Màu",
        "desc": "Tận dụng ánh đèn đường, biển hiệu quán ăn và độ nhạy film cao để tạo nên những bức ảnh đêm lung linh đầy hoài niệm.",
        "category": "Kỹ thuật nhiếp ảnh",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "chup anh dem hat grain, anh film ban dem, chup anh neon vintage, meo chup anh dem",
        "content": """
        <p>Ảnh film chụp đêm không cần sáng trưng như camera AI. Hãy để vùng tối đen sâu tự nhiên và đón lấy những vệt sáng vàng cam từ đèn đường và bóng nước.</p>
        """
    },
    {
        "slug": "trao-luu-may-anh-ccd-ky-thuat-so-y2k",
        "title": "Trào Lưu Máy Ảnh Kỹ Thuật Số CCD: Vì Sao Giới Trẻ Mê Mẩn Ảnh Y2K?",
        "desc": "Lý giải cơn sốt săn lùng máy ảnh kỹ thuật số đời đầu và cách chụp tone màu CCD rực rỡ trên điện thoại.",
        "category": "Văn hóa Retro",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "may anh ccd, trao luu y2k digicam, anh ky thuat so 2000s, phong cach retro y2k",
        "content": """
        <p>Cảm biến CCD thập niên 2000 tái tạo màu da hồng hào và độ tương phản đặc trưng mà các cảm biến hiện đại đã làm mất đi. Khám phá sức hút khó cưỡng của phong cách Y2K.</p>
        """
    },
    {
        "slug": "am-thanh-man-trap-co-hoc-va-cam-xuc-chup-anh",
        "title": "Âm Thanh Màn Trập Cơ Học: Yếu Tố Đánh Thức Cảm Hứng Nhiếp Ảnh",
        "desc": "Vì sao tiếng 'tách' giòn tan của lá thép hay tiếng mô tơ cuộn phim lại khiến trải nghiệm chụp ảnh trở nên thỏa mãn đến vậy?",
        "category": "Văn hóa Retro",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "tieng man trap may anh, am thanh camera analog, cam giac chup may film, trai nghiem xuc giac",
        "content": """
        <p>Âm thanh vật lý của máy ảnh cơ mang lại cảm giác hành động có trọng lượng, giúp bạn trân trọng từng khoảnh khắc bấm chụp thay vì chụp hàng loạt vô nghĩa.</p>
        """
    },
    {
        "slug": "phan-biet-app-chup-film-that-va-app-ap-filter",
        "title": "Phân Biệt App Chụp Film Quang Học Thật Và App Áp Filter Màu Thông Thường",
        "desc": "Sự khác nhau cốt lõi giữa việc xử lý shader quang học thời gian thực và việc dán một lớp màu tĩnh (filter overlay) lên ảnh chụp.",
        "category": "Đánh giá ứng dụng",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "app may film that vs filter, live viewfinder, shader quang hoc, chat luong anh film",
        "content": """
        <p>Khung ngắm quang học mô phỏng trực tiếp hạt grain, độ méo rìa kính và vùng nén sáng trước khi bấm chụp, đem lại cảm xúc bấm máy chân thật gấp nhiều lần việc chỉnh màu sau khi chụp.</p>
        """
    },
    {
        "slug": "hieu-ung-quang-hoc-halation-la-gi",
        "title": "Hiệu Ứng Halation Là Gì? Vệt Đỏ Quanh Vùng Sáng Trong Phim Điện Ảnh",
        "desc": "Tìm hiểu hiện tượng tán xạ ánh sáng qua đế phim tạo nên vệt hào quang đỏ cam quyến rũ trên các cuộn phim điện ảnh như Cinestill 800T.",
        "category": "Kỹ thuật nhiếp ảnh",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "hieu ung halation, quang do cinestill, quang hoc film, anh film dien anh",
        "content": """
        <p>Halation là hiện tượng ánh sáng mạnh phản xạ ngược từ mặt sau của lớp phim, tạo ra quầng đỏ huyền ảo quanh bóng đèn và ngọn nến. RfCamera mô phỏng chính xác tán xạ vật lý này.</p>
        """
    },
    {
        "slug": "cong-thuc-chup-anh-film-chan-dung-ngoai-troi",
        "title": "Công Thức Chụp Ảnh Chân Dung Ngoài Trời Tone Màu Trong Trẻo Tự Nhiên",
        "desc": "Cách phối hợp máy ảnh FXN 2 với ánh sáng tự nhiên để có làn da mịn màng, dải tương phản dịu và màu sắc thanh lịch.",
        "category": "Công thức chụp ảnh",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "cong thuc chan dung film, fxn 2, mau da tu nhien, chup anh ngoai troi",
        "content": """
        <p>Chân dung ngoài trời đòi hỏi dải tương phản dịu nhẹ để giữ chi tiết tóc và nếp áo. Cấu hình FXN 2 là lựa chọn tối ưu cho những buổi dạo phố nhẹ nhàng.</p>
        """
    },
    {
        "slug": "chup-anh-film-khi-di-du-lich-khong-can-may-co",
        "title": "Du Lịch Gọn Nhẹ: Chụp Trọn Chuyến Đi Bằng App Máy Film Không Cần Mang Máy Cơ",
        "desc": "Tránh nỗi lo qua máy soi sân bay làm hỏng cuộn phim. Cách ghi lại nhật ký du lịch bằng ứng dụng máy film offline tiện lợi.",
        "category": "Kỹ thuật nhiếp ảnh",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "du lich chup may film, app film du lich, chup anh khong mang may nang, nhat ky du lich",
        "content": """
        <p>Mang máy film cơ đi du lịch đòi hỏi bảo quản cuộn phim cẩn thận trước máy quét X-ray. Sử dụng app máy film thuần offline giúp bạn bắt trọn khoảnh khắc nhẹ nhàng và an tâm.</p>
        """
    },
    {
        "slug": "vi-sao-anh-film-chua-bao-gio-loi-thoi",
        "title": "Vì Sao Ảnh Film Chưa Bao Giờ Lỗi Thời Trong Thời Đại Camera AI?",
        "desc": "Giá trị của sự không hoàn hảo: Hạt grain, vệt xước, lóa sáng và tính chân thực vượt thời gian của ảnh analog.",
        "category": "Văn hóa Retro",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "gia tri anh film, camera ai vs may film, tinh chan thuc nhiep anh, phong cach vintage",
        "content": """
        <p>Khi camera AI làm mịn da quá đà và cân chỉnh màu nhân tạo, con người lại khao khát tìm về những tì vết chân thật: một vệt lóa sáng ngẫu nhiên, một hạt grain sần sùi mang hơi thở cuộc sống.</p>
        """
    },
    {
        "slug": "cach-chia-se-anh-film-len-instagram-story-threads",
        "title": "Cách Đăng Ảnh Film Lên Instagram Story & Threads Chuẩn Tỷ Lệ Đẹp",
        "desc": "Mẹo canh tỷ lệ dọc 4:5 và khung đôi Half-frame kèm date stamp cổ điển để bức ảnh của bạn nổi bật trên mạng xã hội.",
        "category": "Mạng xã hội & Viral",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "dang anh film instagram, story film threads, ty le 4:5 instagram, date stamp dep",
        "content": """
        <p>Tỷ lệ 4:5 chiếm trọn màn hình điện thoại khi lướt feed, kết hợp cùng dấu in ngày tháng màu cam tạo nên dấu ấn thị giác lôi cuốn người xem dừng lại tương tác.</p>
        """
    },
    {
        "slug": "chup-anh-flash-truc-dien-phong-cach-editorial",
        "title": "Chụp Flash Trực Diện: Phong Cách Ảnh Tiệc Đêm Nổi Loạn Thập Niên 90",
        "desc": "Kỹ thuật đánh flash trực tiếp tạo bóng đổ viền sắc nét, làm nổi bật chủ thể trong các buổi tiệc tối và ảnh thời trang đường phố.",
        "category": "Kỹ thuật nhiếp ảnh",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "chup flash truc dien, anh tiec 90s, flash editorial portrait, phong cach retro party",
        "content": """
        <p>Đánh flash trực tiếp không khuếch tán tạo nên độ tương phản gắt gỏng và ánh nhìn tự tin, là phong cách được các tạp chí thời trang và ngôi sao ưa chuộng.</p>
        """
    },
    {
        "slug": "top-cong-thuc-film-den-trang-nghe-thuat",
        "title": "3 Công Thức Màu Film Đen Trắng Cho Kiến Trúc, Đời Thường Và Chân Dung",
        "desc": "Thiết lập thông số GR D để có những bức ảnh đen trắng giàu chiều sâu và cảm xúc thị giác mạnh mẽ.",
        "category": "Công thức chụp ảnh",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "cong thuc film den trang, gr d recipe, anh kien truc den trang, anh doi thuong b&w",
        "content": """
        <p>Khám phá 3 công thức đen trắng: Tương phản gắt cho kiến trúc hiện đại, hạt grain thô cho phố mưa, và sắc độ xám mịn cho chân dung nội tâm.</p>
        """
    },
    {
        "slug": "bo-cuc-anh-vuong-1-1-toi-gian",
        "title": "Làm Chủ Bố Cục Vuông 1:1: Nghệ Thuật Tối Giản Cân Bằng Thị Giác",
        "desc": "Cách tận dụng tỷ lệ vuông 1:1 của máy ảnh Polaroid để tạo nên những bức ảnh tối giản, cân đối và tập trung vào chủ thể.",
        "category": "Kỹ thuật nhiếp ảnh",
        "readTime": "4 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "bo cuc vuong 1:1, nhiep anh toi gian, anh vuong polaroid, meo chup anh vuong",
        "content": """
        <p>Tỷ lệ vuông triệt tiêu sự phân tâm theo chiều ngang hoặc dọc, buộc người chụp phải đặt chủ thể vào vị trí trung tâm hoặc đường chia đối xứng chuẩn mực.</p>
        """
    },
    {
        "slug": "kien-truc-xu-ly-anh-offline-tren-rfcamera",
        "title": "Bên Trong RfCamera: Công Nghệ Xử Lý Ảnh GPU Nhanh 200ms Thuần Offline",
        "desc": "Khám phá cách RfCamera tráng ảnh độ phân giải 12MP trong Isolate nền chỉ trong tích tắc mà không làm đơ khung ngắm.",
        "category": "Bảo mật & Công nghệ",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "kien truc xu ly anh flutter, gpu isolate bake, toc do chup anh film, cong nghe rfcamera",
        "content": """
        <p>Bằng cách tách biệt luồng hiển thị giao diện và luồng xử lý ma trận màu trong Dart Isolate, RfCamera đảm bảo trải nghiệm chụp ảnh liên tục không giật lag.</p>
        """
    },
    {
        "slug": "lich-su-va-su-phat-trien-cua-may-anh-rangefinder",
        "title": "Lịch Sử Máy Ảnh Rangefinder 35mm: Từ Biểu Tượng Phóng Sự Đến Ứng Dụng Di Động",
        "desc": "Hành trình của dòng máy ảnh đo cự ly Rangefinder huyền thoại Leica, Contax và cách RfCamera tái hiện tinh thần này.",
        "category": "Văn hóa Retro",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "lich su may anh rangefinder, may anh leica contax, nguyen ly do cu ly 35mm, van hoa chup film",
        "content": """
        <p>Khung ngắm Rangefinder cho phép nhiếp ảnh gia quan sát cả những gì đang diễn ra bên ngoài khung hình trước khi chủ thể bước vào, tạo nên phản xạ nắm bắt khoảnh khắc thần tốc.</p>
        """
    },
    {
        "slug": "huong-dan-chup-anh-film-cho-nguoi-moi-bat-dau",
        "title": "Hướng Dẫn Chụp Ảnh Film Cho Người Mới Bắt Đầu: 5 Nguyên Tắc Vàng",
        "desc": "Những lưu ý quan trọng về ánh sáng, khoảng cách lấy nét, chọn thân máy và cách kiên nhẫn quan sát trước khi bấm máy.",
        "category": "Kỹ thuật nhiếp ảnh",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "huong dan chup may film, nhiep anh film can ban, meo chup may film nguoi moi, hoc chup anh vintage",
        "content": """
        <p>Nhiếp ảnh film không phải là bấm máy liên tục rồi chọn ảnh. Đó là nghệ thuật quan sát ánh sáng, dự đoán chuyển động và bấm chụp với sự tập trung cao độ.</p>
        """
    },
    {
        "slug": "tuong-lai-cua-ung-dung-nhiep-anh-thu-cong",
        "title": "Tương Lai Của Ứng Dụng Nhiếp Ảnh: Tôn Trọng Quyền Riêng Tư Và Cảm Giác Cơ Khí",
        "desc": "Vì sao mô hình miễn phí, thuần offline và loại bỏ quảng cáo như RfCamera sẽ là xu thế bền vững của kỷ nguyên phần mềm mới.",
        "category": "Văn hóa Retro",
        "readTime": "5 phút đọc",
        "date": "28 Tháng 8, 2026",
        "keywords": "tuong lai ung dung camera, app khong thu phi, phan mem ton trong nguoi dung, rfcamera blog",
        "content": """
        <p>Người dùng đang mệt mỏi với các gói thuê bao định kỳ và nỗi lo lộ dữ liệu cá nhân. Một ứng dụng miễn phí, bền bỉ, 100% offline và chú trọng xúc giác sẽ luôn giữ vị trí đặc biệt trong lòng người yêu nhiếp ảnh.</p>
        """
    }
]

# Base template for individual article page
def render_article_html(art, lang='en'):
    back_text = "← Back to Articles" if lang == 'en' else "← Quay lại danh sách bài viết"
    app_cta_title = "Get RfCamera on your device" if lang == 'en' else "Cài đặt RfCamera vào túi quần bạn"
    app_cta_desc = "12 classic analog film cameras. 100% offline, zero accounts, completely free." if lang == 'en' else "12 máy film analog kinh điển. 100% offline, không tài khoản, miễn phí trọn đời."
    download_ios = "Download on App Store" if lang == 'en' else "Tải trên App Store"
    download_android = "Get it on Google Play" if lang == 'en' else "Tải trên Google Play"
    
    html = f"""<!DOCTYPE html>
<html lang="{lang}">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{art['title']} — RfCamera Blog</title>
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

  <!-- Schema.org Article -->
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
      "name": "RfCamera Editorial Team",
      "url": "https://rfcam.roycorp.xyz"
    }}
  }}
  </script>

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@500;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

  <style>
    :root {{
      --bg: #000000;
      --surface: #111114;
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
      line-height: 1.65;
      padding: 40px 20px 80px;
    }}
    .mono {{ font-family: 'JetBrains Mono', monospace; }}
    .container {{
      max-width: 760px;
      margin: 0 auto;
      display: flex;
      flex-direction: column;
      gap: 28px;
    }}
    .back-nav {{
      color: var(--orange);
      text-decoration: none;
      font-weight: 700;
      font-size: 14px;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }}
    .meta-bar {{
      display: flex;
      align-items: center;
      gap: 12px;
      font-size: 12px;
      color: var(--text-muted);
    }}
    .tag {{
      background: rgba(255, 122, 47, 0.15);
      color: var(--orange);
      padding: 3px 8px;
      border-radius: 4px;
      font-weight: 700;
    }}
    h1 {{
      font-size: 36px;
      font-weight: 900;
      letter-spacing: -0.03em;
      line-height: 1.2;
      color: #fff;
    }}
    .article-content {{
      color: #D8D8E0;
      font-size: 16.5px;
      display: flex;
      flex-direction: column;
      gap: 18px;
    }}
    .article-content h2 {{
      font-size: 24px;
      font-weight: 800;
      color: #fff;
      margin-top: 20px;
    }}
    .article-content p {{
      line-height: 1.7;
    }}
    .article-content ul, .article-content ol {{
      padding-left: 24px;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }}
    .article-content a {{
      color: var(--orange);
      text-decoration: underline;
    }}
    .article-content table {{
      width: 100%;
      border-collapse: collapse;
      margin: 16px 0;
      font-size: 14.5px;
    }}
    .article-content th, .article-content td {{
      padding: 12px 14px;
      border: 1px solid var(--border);
      text-align: left;
    }}
    .article-content th {{
      background: var(--surface);
      color: #fff;
    }}
    .cta-box {{
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 32px 28px;
      text-align: center;
      margin-top: 36px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 16px;
    }}
    .cta-box h3 {{ font-size: 22px; font-weight: 800; }}
    .cta-box p {{ color: var(--text-muted); font-size: 14.5px; max-width: 480px; }}
    .cta-btn-row {{ display: flex; gap: 10px; flex-wrap: wrap; justify-content: center; }}
    .btn {{
      padding: 12px 20px;
      border-radius: 10px;
      font-weight: 800;
      font-size: 14px;
      text-decoration: none;
      transition: transform 0.15s ease;
    }}
    .btn.primary {{ background: #fff; color: #000; }}
    .btn.secondary {{ background: #1C1C22; color: #fff; border: 1px solid var(--border); }}
    .btn:hover {{ transform: translateY(-2px); }}
  </style>
</head>
<body>
  <div class="container">
    <a href="/blog/" class="back-nav">{back_text}</a>
    
    <div class="meta-bar">
      <span class="tag mono">{art['category']}</span>
      <span>•</span>
      <span>{art['readTime']}</span>
      <span>•</span>
      <span>{art['date']}</span>
    </div>

    <h1>{art['title']}</h1>

    <div class="article-content">
      {art['content']}
    </div>

    <div class="cta-box">
      <h3>{app_cta_title}</h3>
      <p>{app_cta_desc}</p>
      <div class="cta-btn-row">
        <a href="https://rfcam.roycorp.xyz/" class="btn primary">{download_ios}</a>
        <a href="https://play.google.com/store/apps/details?id=xyz.roycorp.rfcam" class="btn secondary">{download_android}</a>
      </div>
    </div>
  </div>
</body>
</html>"""
    return html

# Write all 25 EN articles
for a in en_articles:
    path = f"landing/blog/{a['slug']}.html"
    with open(path, 'w', encoding='utf-8') as f:
        f.write(render_article_html(a, 'en'))

# Write all 25 VN articles
for a in vn_articles:
    path = f"landing/blog/{a['slug']}.html"
    with open(path, 'w', encoding='utf-8') as f:
        f.write(render_article_html(a, 'vi'))

# Render Blog Index Hub
all_articles = [
    {**a, "lang": "English", "url": f"/blog/{a['slug']}.html"} for a in en_articles
] + [
    {**a, "lang": "Tiếng Việt", "url": f"/blog/{a['slug']}.html"} for a in vn_articles
]

blog_cards_html = ""
for art in all_articles:
    badge_color = "#FF7A2F" if art["lang"] == "English" else "#30D158"
    blog_cards_html += f"""
    <a href="{art['url']}" class="blog-card" data-lang="{art['lang'].lower()}">
      <div class="card-top">
        <span class="lang-tag mono" style="color: {badge_color};">{art['lang']}</span>
        <span class="cat-tag">{art['category']}</span>
      </div>
      <h2 class="card-title">{art['title']}</h2>
      <p class="card-desc">{art['desc']}</p>
      <div class="card-footer mono">{art['readTime']} • {art['date']}</div>
    </a>
    """

blog_index_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>RfCamera Blog — 50 Guides to Vintage Film Photography & Analog Cameras</title>
  <meta name="description" content="Explore 50 comprehensive guides, recipes, and tech breakdowns on 35mm film photography, vintage camera emulations, Dazz Cam alternatives, and offline camera security." />
  <link rel="canonical" href="https://rfcam.roycorp.xyz/blog/" />

  <!-- Open Graph -->
  <meta property="og:type" content="website" />
  <meta property="og:url" content="https://rfcam.roycorp.xyz/blog/" />
  <meta property="og:title" content="RfCamera Blog — 50 Film Photography & Camera Guides" />
  <meta property="og:description" content="Master 35mm film looks, recipes, and vintage camera emulations with RfCamera." />
  <meta property="og:image" content="https://rfcam.pages.dev/assets/og_image.png" />

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@500;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

  <style>
    :root {{
      --bg: #000000;
      --surface: #111114;
      --surface-hover: #18181F;
      --border: #222228;
      --text: #FFFFFF;
      --text-muted: #8E8E96;
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
    .header-wrap {{
      max-width: 1140px;
      margin: 0 auto 40px;
      display: flex;
      flex-direction: column;
      gap: 16px;
    }}
    .back-home {{
      color: var(--orange);
      text-decoration: none;
      font-weight: 800;
      font-size: 13.5px;
    }}
    h1 {{
      font-size: 44px;
      font-weight: 900;
      letter-spacing: -0.03em;
      line-height: 1.1;
    }}
    h1 span {{ color: var(--orange); }}
    .sub {{
      font-size: 17px;
      color: var(--text-muted);
      max-width: 600px;
    }}
    .filter-bar {{
      display: flex;
      gap: 10px;
      margin-top: 10px;
      flex-wrap: wrap;
    }}
    .filter-btn {{
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
    .filter-btn.active {{
      background: var(--orange);
      color: #000;
      border-color: var(--orange);
    }}
    .grid {{
      max-width: 1140px;
      margin: 0 auto;
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 16px;
    }}
    @media (max-width: 900px) {{
      .grid {{ grid-template-columns: repeat(2, 1fr); }}
    }}
    @media (max-width: 600px) {{
      .grid {{ grid-template-columns: 1fr; }}
      h1 {{ font-size: 32px; }}
    }}
    .blog-card {{
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 20px;
      text-decoration: none;
      color: inherit;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      gap: 12px;
      transition: transform 0.15s ease, border-color 0.15s ease;
    }}
    .blog-card:hover {{
      transform: translateY(-3px);
      border-color: rgba(255, 255, 255, 0.25);
      background: var(--surface-hover);
    }}
    .card-top {{
      display: flex;
      align-items: center;
      justify-content: space-between;
      font-size: 11px;
    }}
    .lang-tag {{
      font-weight: 800;
    }}
    .cat-tag {{
      color: var(--text-muted);
    }}
    .card-title {{
      font-size: 16.5px;
      font-weight: 800;
      line-height: 1.35;
      color: #fff;
    }}
    .card-desc {{
      font-size: 13px;
      color: var(--text-muted);
      line-height: 1.45;
    }}
    .card-footer {{
      font-size: 11px;
      color: #555560;
      padding-top: 8px;
      border-top: 1px solid rgba(255, 255, 255, 0.05);
    }}
  </style>
</head>
<body>
  <div class="header-wrap">
    <a href="/" class="back-home">← RfCamera Home</a>
    <h1>RfCamera <span>Blog & Guides</span></h1>
    <p class="sub">50 in-depth photography guides, film recipes, camera emulations, and privacy-first engineering breakdowns.</p>
    
    <div class="filter-bar">
      <button class="filter-btn active" onclick="filterArticles('all')">All 50 Articles</button>
      <button class="filter-btn" onclick="filterArticles('english')">English (25)</button>
      <button class="filter-btn" onclick="filterArticles('tiếng việt')">Tiếng Việt (25)</button>
    </div>
  </div>

  <div class="grid" id="article-grid">
    {blog_cards_html}
  </div>

  <script>
    function filterArticles(filter) {{
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      event.target.classList.add('active');

      const cards = document.querySelectorAll('.blog-card');
      cards.forEach(card => {{
        const lang = card.getAttribute('data-lang');
        if (filter === 'all' || lang === filter.toLowerCase()) {{
          card.style.display = 'flex';
        }} else {{
          card.style.display = 'none';
        }}
      }});
    }}
  </script>
</body>
</html>"""

with open("landing/blog/index.html", "w", encoding="utf-8") as f:
    f.write(blog_index_html)

# Generate Sitemap.xml
sitemap_urls = [
    "https://rfcam.roycorp.xyz/",
    "https://rfcam.roycorp.xyz/blog/"
] + [f"https://rfcam.roycorp.xyz/blog/{a['slug']}.html" for a in en_articles + vn_articles]

sitemap_xml = '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
for u in sitemap_urls:
    sitemap_xml += f'  <url>\n    <loc>{u}</loc>\n    <lastmod>2026-08-28</lastmod>\n    <changefreq>weekly</changefreq>\n    <priority>0.8</priority>\n  </url>\n'
sitemap_xml += '</urlset>'

with open("landing/sitemap.xml", "w", encoding="utf-8") as f:
    f.write(sitemap_xml)

with open("landing/robots.txt", "w", encoding="utf-8") as f:
    f.write("User-agent: *\nAllow: /\nSitemap: https://rfcam.roycorp.xyz/sitemap.xml\n")

print(f"Generated {len(en_articles)} EN + {len(vn_articles)} VN = {len(all_articles)} SEO Articles, Blog Hub, Sitemap, and Robots.txt successfully!")
