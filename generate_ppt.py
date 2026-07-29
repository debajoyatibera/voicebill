import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

def create_deck():
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_layout = prs.slide_layouts[6]

    # Theme Colors (Modern Premium Dark Tech Theme)
    BG_DARK = RGBColor(11, 19, 43)        # Deep Slate / Midnight Navy
    CARD_BG = RGBColor(28, 37, 65)        # Dark Card Indigo
    ACCENT_CYAN = RGBColor(0, 245, 212)   # Neon Cyan
    ACCENT_BLUE = RGBColor(0, 180, 216)   # Sky Teal
    ACCENT_GOLD = RGBColor(255, 183, 3)   # Amber Gold
    ACCENT_CORAL = RGBColor(255, 65, 108) # Glowing Coral
    TEXT_WHITE = RGBColor(255, 255, 255)  # Pure White
    TEXT_SILVER = RGBColor(148, 163, 184) # Light Slate
    TEXT_DARK = RGBColor(15, 23, 42)      # Deep Dark for badges

    def apply_background(slide):
        bg = slide.background
        fill = bg.fill
        fill.solid()
        fill.fore_color.rgb = BG_DARK

    def add_header(slide, title_text, subtitle_text=""):
        apply_background(slide)
        
        # Header Accent Strip
        strip = slide.shapes.add_shape(
            MSO_SHAPE.RECTANGLE,
            Inches(0.8), Inches(0.5), Inches(1.8), Inches(0.08)
        )
        strip.fill.solid()
        strip.fill.fore_color.rgb = ACCENT_CYAN
        strip.line.fill.background()
        
        # Title
        title_box = slide.shapes.add_textbox(
            Inches(0.8), Inches(0.65), Inches(11.5), Inches(0.8)
        )
        tf = title_box.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = title_text
        p.font.bold = True
        p.font.size = Pt(32)
        p.font.color.rgb = TEXT_WHITE
        p.font.name = "Segoe UI"

        # Subtitle
        if subtitle_text:
            p2 = tf.add_paragraph()
            p2.text = subtitle_text
            p2.font.size = Pt(16)
            p2.font.color.rgb = ACCENT_BLUE
            p2.font.name = "Segoe UI"
            p2.space_before = Pt(6)

        # Footer badge
        footer = slide.shapes.add_textbox(
            Inches(0.8), Inches(6.9), Inches(11.5), Inches(0.4)
        )
        ftf = footer.text_frame
        fp = ftf.paragraphs[0]
        fp.text = "VoiceBill  •  Hack Synthesis 3.0 (UEM Kolkata)  •  Open Innovation  •  debajoyatibera.github.io/voicebill"
        fp.font.size = Pt(11)
        fp.font.color.rgb = TEXT_SILVER
        fp.font.name = "Segoe UI"

    def add_card(slide, left, top, width, height, bg_color=CARD_BG, border_color=None):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        card.fill.solid()
        card.fill.fore_color.rgb = bg_color
        if border_color:
            card.line.color.rgb = border_color
            card.line.width = Pt(1.5)
        else:
            card.line.fill.background()
        return card

    # -------------------------------------------------------------
    # SLIDE 1: Title & Hero Slide
    # -------------------------------------------------------------
    slide1 = prs.slides.add_slide(blank_layout)
    apply_background(slide1)
    
    # Left Hero Accent Bar
    bar = slide1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.5), Inches(0.2), Inches(4.5))
    bar.fill.solid()
    bar.fill.fore_color.rgb = ACCENT_CYAN
    bar.line.fill.background()

    # Main Hero Title
    hero_box = slide1.shapes.add_textbox(Inches(1.3), Inches(1.5), Inches(11.0), Inches(2.5))
    htf = hero_box.text_frame
    htf.word_wrap = True
    
    hp1 = htf.paragraphs[0]
    hp1.text = "VoiceBill 🎙️🧾"
    hp1.font.bold = True
    hp1.font.size = Pt(54)
    hp1.font.color.rgb = TEXT_WHITE
    hp1.font.name = "Segoe UI"

    hp2 = htf.add_paragraph()
    hp2.text = "Multilingual Voice-First Billing & POS App for Indian Street Vendors"
    hp2.font.bold = True
    hp2.font.size = Pt(24)
    hp2.font.color.rgb = ACCENT_CYAN
    hp2.space_before = Pt(12)

    hp3 = htf.add_paragraph()
    hp3.text = "Empowering 50M+ Vendors with Speech AI, Instant WhatsApp Reports & CSV Spreadsheet Export"
    hp3.font.size = Pt(18)
    hp3.font.color.rgb = TEXT_SILVER
    hp3.space_before = Pt(8)

    # Team Card
    card_team = add_card(slide1, Inches(1.3), Inches(4.3), Inches(5.4), Inches(2.0), CARD_BG, ACCENT_BLUE)
    ttf = card_team.text_frame
    ttf.word_wrap = True
    ttf.margin_left = Inches(0.3)
    ttf.margin_top = Inches(0.25)
    
    tp1 = ttf.paragraphs[0]
    tp1.text = "TEAM VOICEBILL — HACK SYNTHESIS 3.0"
    tp1.font.bold = True
    tp1.font.size = Pt(14)
    tp1.font.color.rgb = ACCENT_GOLD
    
    tp2 = ttf.add_paragraph()
    tp2.text = "• Debajoyati Bera (Team Leader)"
    tp2.font.size = Pt(16)
    tp2.font.color.rgb = TEXT_WHITE
    tp2.space_before = Pt(10)
    
    tp3 = ttf.add_paragraph()
    tp3.text = "• Souvik Adak (Team Member)"
    tp3.font.size = Pt(16)
    tp3.font.color.rgb = TEXT_WHITE
    tp3.space_before = Pt(6)
    
    tp4 = ttf.add_paragraph()
    tp4.text = "University of Engineering & Management (UEM) Kolkata"
    tp4.font.size = Pt(12)
    tp4.font.color.rgb = TEXT_SILVER
    tp4.space_before = Pt(8)

    # Live Demo Badge Card
    card_demo = add_card(slide1, Inches(7.0), Inches(4.3), Inches(5.2), Inches(2.0), CARD_BG, ACCENT_CYAN)
    dtf = card_demo.text_frame
    dtf.word_wrap = True
    dtf.margin_left = Inches(0.3)
    dtf.margin_top = Inches(0.3)
    
    dp1 = dtf.paragraphs[0]
    dp1.text = "🌐 OPEN INNOVATION — LIVE DEMO"
    dp1.font.bold = True
    dp1.font.size = Pt(14)
    dp1.font.color.rgb = ACCENT_CYAN
    
    dp2 = dtf.add_paragraph()
    dp2.text = "https://debajoyatibera.github.io/voicebill/"
    dp2.font.bold = True
    dp2.font.size = Pt(17)
    dp2.font.color.rgb = TEXT_WHITE
    dp2.space_before = Pt(12)

    dp3 = dtf.add_paragraph()
    dp3.text = "Tested, Live & Accessible Online on GitHub Pages across Mobile & Desktop browsers!"
    dp3.font.size = Pt(13)
    dp3.font.color.rgb = TEXT_SILVER
    dp3.space_before = Pt(10)

    # -------------------------------------------------------------
    # SLIDE 2: The Real-World Problem
    # -------------------------------------------------------------
    slide2 = prs.slides.add_slide(blank_layout)
    add_header(slide2, "1. The Real-World Problem", "Why 50+ Million Indian Street Vendors Are Excluded from Digital POS Apps")

    problems = [
        ("⌨️ Touchscreen Typing Friction", 
         "Traditional POS apps require rapid typing on small smartphone keyboards. For vendors cooking tea, handling vegetables, or managing crowded stalls, typing is painfully slow and distracting.",
         ACCENT_CORAL),
        ("🗣️ Literacy & Language Barrier", 
         "Most billing apps force English menu hierarchies or rigid forms. India's hawkers speak natural vernacular dialects (Hindi, Bengali, Indian English) and need an interface that listens to how they speak.",
         ACCENT_GOLD),
        ("📝 Lost Accounting & Disputes", 
         "Vendors rely on mental math or paper chits, resulting in lost daily totals, billing errors, customer disputes, and an inability to track revenue or share records with accountants.",
         ACCENT_BLUE)
    ]

    for i, (p_title, p_desc, col) in enumerate(problems):
        x = Inches(0.8 + i * 3.9)
        c = add_card(slide2, x, Inches(1.8), Inches(3.6), Inches(4.5), CARD_BG, col)
        tf = c.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.25)
        tf.margin_top = Inches(0.3)
        tf.margin_right = Inches(0.25)
        
        p1 = tf.paragraphs[0]
        p1.text = p_title
        p1.font.bold = True
        p1.font.size = Pt(20)
        p1.font.color.rgb = col
        
        p2 = tf.add_paragraph()
        p2.text = p_desc
        p2.font.size = Pt(15)
        p2.font.color.rgb = TEXT_WHITE
        p2.space_before = Pt(18)

    # -------------------------------------------------------------
    # SLIDE 3: Our Solution — VoiceBill
    # -------------------------------------------------------------
    slide3 = prs.slides.add_slide(blank_layout)
    add_header(slide3, "2. Our Solution — VoiceBill", "A Keyless, Multilingual Voice-First Billing & Accounting App")

    # Value Prop Banner
    vp = add_card(slide3, Inches(0.8), Inches(1.8), Inches(11.7), Inches(1.3), CARD_BG, ACCENT_CYAN)
    vtf = vp.text_frame
    vtf.word_wrap = True
    vtf.margin_left = Inches(0.4)
    vtf.margin_top = Inches(0.25)
    vp1 = vtf.paragraphs[0]
    vp1.text = '💡 Just speak naturally: "do chai, panch panch rupaye" or "tin samosa, bees rupaye"'
    vp1.font.bold = True
    vp1.font.size = Pt(21)
    vp1.font.color.rgb = TEXT_WHITE
    vp2 = vtf.add_paragraph()
    vp2.text = "VoiceBill listens in Hindi, Bengali, or English, uses AI to extract structured items & prices, calculates daily totals out loud, and shares instant business reports with 1-tap."
    vp2.font.size = Pt(15)
    vp2.font.color.rgb = ACCENT_CYAN
    vp2.space_before = Pt(6)

    # 4 Workflow Steps
    steps = [
        ("1. Tap & Speak", "Tap the glowing mic button and say items & prices in vernacular speech."),
        ("2. AI Intelligence", "Gemini 1.5 Flash AI parses speech into item, quantity & unit price."),
        ("3. TTS Audio Readback", "Speaks aloud the sale & running daily collection in rupees for instant confirmation."),
        ("4. 1-Tap Export", "Launch WhatsApp report synchronously or download an Excel CSV spreadsheet.")
    ]
    for i, (st_title, st_desc) in enumerate(steps):
        x = Inches(0.8 + i * 2.95)
        c = add_card(slide3, x, Inches(3.4), Inches(2.75), Inches(3.1), CARD_BG, ACCENT_BLUE)
        tf = c.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.2)
        tf.margin_top = Inches(0.25)
        tf.margin_right = Inches(0.2)
        
        sp1 = tf.paragraphs[0]
        sp1.text = st_title
        sp1.font.bold = True
        sp1.font.size = Pt(18)
        sp1.font.color.rgb = ACCENT_GOLD
        
        sp2 = tf.add_paragraph()
        sp2.text = st_desc
        sp2.font.size = Pt(14)
        sp2.font.color.rgb = TEXT_WHITE
        sp2.space_before = Pt(14)

    # -------------------------------------------------------------
    # SLIDE 4: System Architecture & Keyless Security Flow
    # -------------------------------------------------------------
    slide4 = prs.slides.add_slide(blank_layout)
    add_header(slide4, "3. System Architecture & Keyless Security", "Zero API Keys Exposed on Client — Serverless GCP & Appwrite Proxy")

    arch_blocks = [
        ("1. CLIENT (Flutter App)", 
         "• Web, Android & iOS\n• speech_to_text (Dictation)\n• SharedPrefs offline store\n• No API keys in bundle",
         ACCENT_CYAN),
        ("2. KEYLESS PROXY", 
         "• Serverless Cloud Run / Appwrite\n• Uses Application Default Credentials (ADC)\n• Rate limits & CORS protection\n• Shields secrets",
         ACCENT_BLUE),
        ("3. AI ENGINE (GCP Vertex AI)", 
         "• Gemini 1.5 Flash\n• Natural language parsing\n• Returns JSON:\n  {item, qty, price, conf}\n• Multi-dialect recognition",
         ACCENT_GOLD),
        ("4. OUTPUT & EXPORT", 
         "• UI Card with Check badge\n• flutter_tts Voice Summary\n• Synchronous WhatsApp wa.me link\n• HTML5 Blob CSV Download",
         ACCENT_CORAL)
    ]

    for i, (b_title, b_desc, col) in enumerate(arch_blocks):
        x = Inches(0.8 + i * 2.95)
        c = add_card(slide4, x, Inches(2.0), Inches(2.75), Inches(4.3), CARD_BG, col)
        tf = c.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.2)
        tf.margin_top = Inches(0.25)
        
        p1 = tf.paragraphs[0]
        p1.text = b_title
        p1.font.bold = True
        p1.font.size = Pt(16)
        p1.font.color.rgb = col
        
        p2 = tf.add_paragraph()
        p2.text = b_desc
        p2.font.size = Pt(14)
        p2.font.color.rgb = TEXT_WHITE
        p2.space_before = Pt(14)

    # -------------------------------------------------------------
    # SLIDE 5: Core Tech Stack
    # -------------------------------------------------------------
    slide5 = prs.slides.add_slide(blank_layout)
    add_header(slide5, "4. Technical Stack & Dependencies", "Modern Cross-Platform Web & Cloud Native Architecture")

    tech_categories = [
        ("📱 Frontend Application", 
         "• Flutter 3 (Web, Android, iOS)\n• CanvasKit High-Performance Renderer\n• Tree-Shaken Font Icons & Optimized WASM/JS\n• Responsive Modal Bottom Sheets & Glassmorphism",
         ACCENT_CYAN),
        ("☁️ AI & Serverless Backend", 
         "• Google Cloud Platform (GCP) Vertex AI\n• Gemini 1.5 Flash Structured JSON Output\n• Cloud Run Container / Appwrite Serverless Proxy\n• Application Default Credentials (ADC) Security",
         ACCENT_BLUE),
        ("🎙️ Voice & Audio Intelligence", 
         "• speech_to_text (ListenMode.dictation)\n• Web Speech API & Native Mobile Audio\n• flutter_tts (Text-to-Speech Hindi/Bengali/English)\n• Dynamic Speech Pause & Timeout Resiliency",
         ACCENT_GOLD),
        ("📊 Export & Storage Engine", 
         "• url_launcher (Synchronous WhatsApp wa.me)\n• dart:html AnchorElement & Blob CSV Excel download\n• shared_preferences (Local JSON Daily Tally)\n• Clipboard SDK text export",
         ACCENT_CORAL)
    ]

    for i, (t_title, t_desc, col) in enumerate(tech_categories):
        x = Inches(0.8 + (i % 2) * 6.0)
        y = Inches(1.8 + (i // 2) * 2.4)
        c = add_card(slide5, x, y, Inches(5.7), Inches(2.1), CARD_BG, col)
        tf = c.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.25)
        tf.margin_top = Inches(0.2)
        
        p1 = tf.paragraphs[0]
        p1.text = t_title
        p1.font.bold = True
        p1.font.size = Pt(18)
        p1.font.color.rgb = col
        
        p2 = tf.add_paragraph()
        p2.text = t_desc
        p2.font.size = Pt(14)
        p2.font.color.rgb = TEXT_WHITE
        p2.space_before = Pt(10)

    # -------------------------------------------------------------
    # SLIDE 6: Key Features & WOW Factors
    # -------------------------------------------------------------
    slide6 = prs.slides.add_slide(blank_layout)
    add_header(slide6, "5. Key Features & Innovation Highlights", "Designed for Real-World Outdoor Street Markets")

    features = [
        ("🎙️ Multilingual Speech POS", "Speaks fluent Hindi, Bengali & Indian English without switching complex keyboards."),
        ("⌨️ Noisy Market Fallback", "Type or paste sale dialog for deafeningly loud train stations or festivals."),
        ("📲 1-Tap WhatsApp Report", "Generates daily markdown sales report and opens WhatsApp synchronously (popup-proof)."),
        ("📊 CSV Spreadsheet Export", "Downloads .csv Excel file with 1 click using web-native Blob anchor download."),
        ("🔊 Audio TTS Readback", "Speaks aloud the itemized order and updated collection in rupees."),
        ("🔒 Zero-Key Cloud Security", "100% keyless frontend using GCP Application Default Credentials and serverless proxy.")
    ]

    for i, (f_title, f_desc) in enumerate(features):
        x = Inches(0.8 + (i % 3) * 3.9)
        y = Inches(1.8 + (i // 3) * 2.4)
        c = add_card(slide6, x, y, Inches(3.6), Inches(2.1), CARD_BG, ACCENT_CYAN if (i%2==0) else ACCENT_BLUE)
        tf = c.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.2)
        tf.margin_top = Inches(0.25)
        tf.margin_right = Inches(0.2)
        
        p1 = tf.paragraphs[0]
        p1.text = f_title
        p1.font.bold = True
        p1.font.size = Pt(18)
        p1.font.color.rgb = ACCENT_GOLD
        
        p2 = tf.add_paragraph()
        p2.text = f_desc
        p2.font.size = Pt(14)
        p2.font.color.rgb = TEXT_WHITE
        p2.space_before = Pt(10)

    # -------------------------------------------------------------
    # SLIDE 7: Live Web Demo & UI Showcase (With Embedded Screenshot)
    # -------------------------------------------------------------
    slide7 = prs.slides.add_slide(blank_layout)
    add_header(slide7, "6. Live Interactive Demo & UI Showcase", "Experience VoiceBill Live Online — No Installation Needed")

    # Left Text & Demo Link Card
    demo_card = add_card(slide7, Inches(0.8), Inches(1.8), Inches(5.6), Inches(4.7), CARD_BG, ACCENT_CYAN)
    dtf = demo_card.text_frame
    dtf.word_wrap = True
    dtf.margin_left = Inches(0.3)
    dtf.margin_top = Inches(0.3)
    
    dp1 = dtf.paragraphs[0]
    dp1.text = "🌐 LIVE GITHUB PAGES DEPLOYMENT"
    dp1.font.bold = True
    dp1.font.size = Pt(15)
    dp1.font.color.rgb = ACCENT_GOLD
    
    dp2 = dtf.add_paragraph()
    dp2.text = "https://debajoyatibera.github.io/voicebill/"
    dp2.font.bold = True
    dp2.font.size = Pt(19)
    dp2.font.color.rgb = TEXT_WHITE
    dp2.space_before = Pt(8)
    
    dp3 = dtf.add_paragraph()
    dp3.text = "We believe in true Open Innovation — our application is fully deployed, tested, and accessible to any judge or street vendor instantly on their browser."
    dp3.font.size = Pt(14)
    dp3.font.color.rgb = TEXT_SILVER
    dp3.space_before = Pt(10)

    dp4 = dtf.add_paragraph()
    dp4.text = "✨ Try This 3-Step Test Right Now:\n" \
               "1. Open link & tap the Glowing Mic button.\n" \
               "2. Speak: \"do chai, panch panch rupaye\" -> see instant AI card & hear rupee readback!\n" \
               "3. Tap green \"WhatsApp\" button -> see daily sales tally open synchronously!"
    dp4.font.size = Pt(14)
    dp4.font.color.rgb = ACCENT_CYAN
    dp4.space_before = Pt(14)

    # Right Screenshot Card & Embedded Picture
    img_card = add_card(slide7, Inches(6.6), Inches(1.8), Inches(5.9), Inches(4.7), CARD_BG, ACCENT_BLUE)
    img_path = os.path.join(os.path.dirname(__file__), "screenshot_demo.png")
    if os.path.exists(img_path):
        slide7.shapes.add_picture(img_path, Inches(6.8), Inches(2.1), Inches(5.5))
    else:
        itf = img_card.text_frame
        ip = itf.paragraphs[0]
        ip.text = "Live App UI Showcase"
        ip.font.size = Pt(20)
        ip.font.color.rgb = ACCENT_CYAN

    # -------------------------------------------------------------
    # SLIDE 8: Technical Challenges & How We Solved Them
    # -------------------------------------------------------------
    slide8 = prs.slides.add_slide(blank_layout)
    add_header(slide8, "7. Technical Challenges & Solutions", "Overcoming Real-World Browser, Speech & Cloud Hurdles")

    challs = [
        ("⚡ WebSpeech API Cutoffs", 
         "Challenge: Web browsers cut off speech recognition during brief pauses in noisy street environments.\n\nSolution: Upgraded to ListenMode.dictation, implemented custom 10-second pause timeouts, and added stop-button transcript capture.",
         ACCENT_CORAL),
        ("🔒 Client API Key Exposure", 
         "Challenge: Embedding Gemini AI API keys in client JavaScript bundles leaves them vulnerable to scraping.\n\nSolution: Architected a keyless Serverless Cloud Run / Appwrite proxy utilizing GCP Application Default Credentials (ADC).",
         ACCENT_GOLD),
        ("🚫 Browser Popup Blockers", 
         "Challenge: Awaiting URL check functions before launching WhatsApp caused Chrome/Safari to silently block new tabs.\n\nSolution: Refactored export button to call launchUrl() synchronously on direct user click and used HTML Blob for CSV downloads.",
         ACCENT_CYAN)
    ]

    for i, (c_title, c_desc, col) in enumerate(challs):
        x = Inches(0.8 + i * 3.9)
        c = add_card(slide8, x, Inches(1.8), Inches(3.6), Inches(4.5), CARD_BG, col)
        tf = c.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.25)
        tf.margin_top = Inches(0.3)
        tf.margin_right = Inches(0.25)
        
        p1 = tf.paragraphs[0]
        p1.text = c_title
        p1.font.bold = True
        p1.font.size = Pt(18)
        p1.font.color.rgb = col
        
        p2 = tf.add_paragraph()
        p2.text = c_desc
        p2.font.size = Pt(14)
        p2.font.color.rgb = TEXT_WHITE
        p2.space_before = Pt(14)

    # -------------------------------------------------------------
    # SLIDE 9: Theme Alignment — Open Innovation
    # -------------------------------------------------------------
    slide9 = prs.slides.add_slide(blank_layout)
    add_header(slide9, "8. Theme Alignment — Open Innovation", "Why VoiceBill Stands Out in Hack Synthesis 3.0")

    impacts = [
        ("🇮🇳 Digital Financial Inclusion", 
         "Brings India's unorganized street retail economy into digital accounting without requiring literacy or English typing skills.",
         ACCENT_CYAN),
        ("💸 Zero Hardware Cost", 
         "Runs on any existing budget smartphone or web browser — no expensive POS terminals or barcode scanners required.",
         ACCENT_BLUE),
        ("🤝 Open Source & Modular", 
         "Clean MIT licensed Flutter codebase and modular serverless GCP proxy designed for community contributions and scaling.",
         ACCENT_GOLD)
    ]

    for i, (i_title, i_desc, col) in enumerate(impacts):
        y = Inches(1.8 + i * 1.6)
        c = add_card(slide9, Inches(0.8), y, Inches(11.7), Inches(1.35), CARD_BG, col)
        tf = c.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.4)
        tf.margin_top = Inches(0.25)
        
        p1 = tf.paragraphs[0]
        p1.text = i_title
        p1.font.bold = True
        p1.font.size = Pt(20)
        p1.font.color.rgb = col
        
        p2 = tf.add_paragraph()
        p2.text = i_desc
        p2.font.size = Pt(15)
        p2.font.color.rgb = TEXT_WHITE
        p2.space_before = Pt(6)

    # -------------------------------------------------------------
    # SLIDE 10: Future Roadmap & Closing
    # -------------------------------------------------------------
    slide10 = prs.slides.add_slide(blank_layout)
    add_header(slide10, "9. Future Roadmap & Vision", "Expanding VoiceBill Across Indian Retail Ecosystems")

    roadmaps = [
        ("Phase 1: Advanced Analytics", 
         "• Multi-day & monthly revenue charts\n• Peak selling hour visualization\n• Item popularity rankings\n• Export to Google Drive/Excel cloud",
         ACCENT_CYAN),
        ("Phase 2: Hardware POS Integration", 
         "• Bluetooth thermal printer integration\n• Print instant paper receipts for customers\n• UPI QR code dynamic payment overlay\n• Offline-first SQLite sync",
         ACCENT_BLUE),
        ("Phase 3: WhatsApp Business AI Bot", 
         "• Automated customer receipt messaging via QR scan\n• AI vendor chatbot for stock replenishment\n• Multilingual voice SMS alerts",
         ACCENT_GOLD)
    ]

    for i, (r_title, r_desc, col) in enumerate(roadmaps):
        x = Inches(0.8 + i * 3.9)
        c = add_card(slide10, x, Inches(1.8), Inches(3.6), Inches(4.5), CARD_BG, col)
        tf = c.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.25)
        tf.margin_top = Inches(0.3)
        tf.margin_right = Inches(0.25)
        
        p1 = tf.paragraphs[0]
        p1.text = r_title
        p1.font.bold = True
        p1.font.size = Pt(18)
        p1.font.color.rgb = col
        
        p2 = tf.add_paragraph()
        p2.text = r_desc
        p2.font.size = Pt(14)
        p2.font.color.rgb = TEXT_WHITE
        p2.space_before = Pt(14)

    out_file = os.path.join(os.path.dirname(__file__), "VoiceBill_HackSynthesis_Presentation.pptx")
    prs.save(out_file)
    print(f"SUCCESS: Generated {out_file}")

if __name__ == "__main__":
    create_deck()
