import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
import arabic_reshaper
from bidi.algorithm import get_display

# Register Arabic Fonts
pdfmetrics.registerFont(TTFont('ArabicRegular', 'C:/Windows/Fonts/arial.ttf'))
pdfmetrics.registerFont(TTFont('ArabicBold', 'C:/Windows/Fonts/arialbd.ttf'))

def ar(text):
    if not text:
        return ""
    # Process line by line if needed or whole text
    reshaped = arabic_reshaper.reshape(str(text))
    return get_display(reshaped)

class ArabicNumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super(ArabicNumberedCanvas, self).__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super(ArabicNumberedCanvas, self).showPage()
        super(ArabicNumberedCanvas, self).save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("ArabicRegular", 8.5)
        self.setFillColor(colors.HexColor("#64748B"))
        
        # Header (pages > 1)
        if self._pageNumber > 1:
            header_text = ar("تطبيق حافظ للهاتف المحمول — دليل المواصفات والمميزات الشاملة")
            self.drawRightString(612 - 54, 792 - 36, header_text)
            self.setStrokeColor(colors.HexColor("#CBD5E1"))
            self.setLineWidth(0.5)
            self.line(54, 792 - 42, 612 - 54, 792 - 42)
            
        # Footer
        footer_page = ar(f"صفحة {self._pageNumber} من {page_count}")
        footer_conf = ar("وثيقة تقنية معتمدة — منصة حافظ التعليمية للبكالوريا (Hafedh EdTech)")
        self.drawString(54, 36, footer_page)
        self.drawRightString(612 - 54, 36, footer_conf)
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.5)
        self.line(54, 46, 612 - 54, 46)
        self.restoreState()

def build_arabic_pdf(filename="Hafedh_Mobile_App_Features_Specification_Arabic.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=48,
        rightMargin=48,
        topMargin=48,
        bottomMargin=48,
    )

    # Color Palette
    primary_color = colors.HexColor("#0D9488")
    primary_dark = colors.HexColor("#0F766E")
    dark_bg = colors.HexColor("#0F172A")
    accent_gold = colors.HexColor("#D97706")
    accent_blue = colors.HexColor("#2563EB")
    accent_purple = colors.HexColor("#7C3AED")
    text_dark = colors.HexColor("#1E293B")
    text_muted = colors.HexColor("#64748B")
    
    # Styles
    title_style = ParagraphStyle(
        'DocTitleAr',
        fontName='ArabicBold',
        fontSize=20,
        leading=24,
        textColor=primary_dark,
        alignment=TA_CENTER,
        spaceAfter=6,
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubtitleAr',
        fontName='ArabicRegular',
        fontSize=11,
        leading=15,
        textColor=text_muted,
        alignment=TA_CENTER,
        spaceAfter=14,
    )
    
    h1_style = ParagraphStyle(
        'Heading1Ar',
        fontName='ArabicBold',
        fontSize=13.5,
        leading=17,
        textColor=primary_dark,
        spaceBefore=12,
        spaceAfter=5,
        alignment=TA_RIGHT,
        keepWithNext=True,
    )

    h2_style = ParagraphStyle(
        'Heading2Ar',
        fontName='ArabicBold',
        fontSize=11,
        leading=14,
        textColor=colors.HexColor("#1E293B"),
        spaceBefore=9,
        spaceAfter=4,
        alignment=TA_RIGHT,
        keepWithNext=True,
    )

    body_style = ParagraphStyle(
        'BodyAr',
        fontName='ArabicRegular',
        fontSize=9,
        leading=13.5,
        textColor=text_dark,
        spaceAfter=5,
        alignment=TA_RIGHT,
    )

    bullet_style = ParagraphStyle(
        'BulletAr',
        parent=body_style,
        rightIndent=12,
        spaceAfter=3,
        alignment=TA_RIGHT,
    )

    callout_style = ParagraphStyle(
        'CalloutAr',
        fontName='ArabicRegular',
        fontSize=8.5,
        leading=12.5,
        textColor=colors.HexColor("#0F766E"),
        alignment=TA_RIGHT,
    )

    table_header_style = ParagraphStyle(
        'TableHeaderAr',
        fontName='ArabicBold',
        fontSize=8.5,
        leading=11,
        textColor=colors.white,
        alignment=TA_CENTER,
    )

    table_cell_style = ParagraphStyle(
        'TableCellAr',
        fontName='ArabicRegular',
        fontSize=8,
        leading=11,
        textColor=text_dark,
        alignment=TA_RIGHT,
    )

    table_cell_bold = ParagraphStyle(
        'TableCellBoldAr',
        fontName='ArabicBold',
        fontSize=8,
        leading=11,
        textColor=primary_dark,
        alignment=TA_RIGHT,
    )

    story = []

    # ==================== COVER & HEADER ====================
    story.append(Paragraph(ar("تطبيق حافظ التعليمي | HAFEDH MOBILE APP"), ParagraphStyle('SuperTitleAr', fontName='ArabicBold', fontSize=10, leading=12, textColor=accent_gold, alignment=TA_CENTER, spaceAfter=4)))
    story.append(Paragraph(ar("دليل المواصفات والمميزات الشاملة وهندسة النظام البرمجية"), title_style))
    story.append(Paragraph(ar("منصة تعليمية ذكية قائمة على التلقيم العمودي بأسلوب التيك توك وخوارزميات التكرار المتباعد للبكالوريا"), subtitle_style))
    
    story.append(HRFlowable(width="100%", thickness=1.5, color=primary_color, spaceBefore=0, spaceAfter=10))

    # Metadata Box Table
    meta_data = [
        [
            Paragraph(ar("إدارة الحالة: Pure Riverpod 2.x"), table_cell_style),
            Paragraph(ar("بيئة العمل: Flutter 3.x / Dart 3.x"), table_cell_style),
            Paragraph(ar("إصدار التطبيق: 1.0.0 (جاهز للإنتاج)"), table_cell_style),
        ],
        [
            Paragraph(ar("الفئة المستهدفة: طلبة البكالوريا (تاريخ وجغرافيا)"), table_cell_style),
            Paragraph(ar("اللغات المدعومة: العربية 🇸🇦، الفرنسية 🇫🇷، الإنجليزية 🇬🇧"), table_cell_style),
            Paragraph(ar("النمط المعماري: Clean Architecture + Offline-First"), table_cell_style),
        ]
    ]
    meta_table = Table(meta_data, colWidths=[172, 172, 172])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F8FAFC")),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#E2E8F0")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 10))

    # ==================== 1. EXECUTIVE SUMMARY ====================
    story.append(Paragraph(ar("1. الملخص التنفيذي والرؤية التعليمية"), h1_style))
    story.append(Paragraph(
        ar("تم تصميم وتطوير تطبيق **حافظ (Hafedh)** كحل ابتكاري جذري لمعالجة معضلة الحفظ التقليدي الممل والنسيان السريع في مادتي التاريخ والجغرافيا لطلبة البكالوريا. يعتمد التطبيق على دمج أسلوب التصفح الجذاب والسريع المستوحى من منصات الفيديو القصيرة (مثل تيك توك) مع الخوارزميات العلمية للإدراك البشري والتكرار المتباعد (SuperMemo SM-2)، مما يحول ساعات الحفظ المجهدة إلى جلسات تفاعلية يومية سريعة وسلسة وممتعة."),
        body_style
    ))

    # Highlights Box
    box_data = [[
        Paragraph(ar("<b>الركائز التقنية والتربوية للتطبيق:</b><br/>"
                     "• <b>تلقيم عمودي فائق السلاسة (TikTok Feed):</b> تصفح عمودي سريع بمعدل 60/120 إطاراً في الثانية.<br/>"
                     "• <b>6 أنماط تفاعلية للبطاقات:</b> أسئلة QCM، بطاقات القلب ثلاثية الأبعاد، تواريخ، شخصيات، مصطلحات، وكبسولات ذاكرة.<br/>"
                     "• <b>خوارزمية إعادة ترتيب البطاقات الذكية (3-Tier Priority):</b> إعطاء الأولوية للبطاقات غير المحفوظة مع خلط عشوائي.<br/>"
                     "• <b>العمل الكامل بدون إنترنت (Offline-First):</b> تخزين مؤقت محلي، وطابور مزامنة المراجعات، ووضع تجريبي فوري.<br/>"
                     "• <b>نظام متعدد اللغات (AR / FR / EN):</b> تبديل فوري بين العربية (RTL) والفرنسية والإنجليزية (LTR)."), callout_style)
    ]]
    box_table = Table(box_data, colWidths=[516])
    box_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F0FDFA")),
        ('BOX', (0, 0), (-1, -1), 1.2, primary_color),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(box_table)
    story.append(Spacer(1, 10))

    # ==================== 2. DETAILED FEATURE BREAKDOWN ====================
    story.append(Paragraph(ar("2. التفصيل التقني والشامل لمميزات التطبيق"), h1_style))
    
    # Feature 2.1
    story.append(Paragraph(ar("2.1 تلقيم التيك توك الذكي والتمرير السلس (TikTok Snapping Feed)"), h2_style))
    story.append(Paragraph(
        ar("يقدم التطبيق تجربة حفظ بصرية فريدة تعتمد على PageView عمودي كامل الشاشة، تم تحسينه برمجياً ليعمل بسرعة فائقة 60fps/120fps بدون أي تقطيع:"),
        body_style
    ))
    story.append(Paragraph(ar("• <b>التجهيز المسبق للبطاقات (allowImplicitScrolling):</b> يقوم بتحميل البطاقة التالية والسابقة في الذاكرة لتكون جاهزة فوراً عند السحب."), bullet_style))
    story.append(Paragraph(ar("• <b>عزل إعادة البناء (Zero-Rebuild Gesture):</b> فصل مستمعات الحالة لضمان عدم إعادة بناء شجرة الواجهة أثناء حركة الإصبع."), bullet_style))
    story.append(Paragraph(ar("• <b>عزل طبقات الرسم (RepaintBoundary):</b> حصر الرسم على مستوى كل بطاقة لتخفيف العبء على معالج الرسوميات (GPU)."), bullet_style))
    story.append(Paragraph(ar("• <b>الانتقال التلقائي الذكي (Auto-Advance):</b> بعد اختيار تقييم الحفظ، ينتقل التلقيم بسلاسة للبطاقة التالية بعد 650 ميلي ثانية."), bullet_style))

    # Feature 2.2
    story.append(Spacer(1, 4))
    story.append(Paragraph(ar("2.2 أنماط البطاقات التفاعلية الستة (6 Flashcard Modalities)"), h2_style))
    story.append(Paragraph(
        ar("لتفادي الملل البصري والذهني، يتم توليد 6 قوالب تفاعلية متخصصة تغطي كافة جوانب المنهاج:"),
        body_style
    ))

    cards_table_data = [
        [Paragraph(ar("الوظيفة البيداغوجية والتفاعلية"), table_header_style), Paragraph(ar("المظهر والتصميم البصري"), table_header_style), Paragraph(ar("نمط البطاقة"), table_header_style)],
        [
            Paragraph(ar("أسئلة اختيار من متعدد تفاعلية مع تصحيح فوري بالأخضر/الأحمر وشرح بيداغوجي تفصيلي للجواب الصحيح."), table_cell_style),
            Paragraph(ar("شارة سماوية + 4 خيارات تفاعلية"), table_cell_style),
            Paragraph(ar("1. سؤال تفاعلي (QCM)"), table_cell_bold)
        ],
        [
            Paragraph(ar("حركة قلب ثلاثية الأبعاد سلسة (3D Matrix4) لكشف الإجابة النموذجية المعتمدة في تصحيح البكالوريا."), table_cell_style),
            Paragraph(ar("شارة زرقاء + تأثير قلب ثلاثي الأبعاد"), table_cell_style),
            Paragraph(ar("2. بطاقة القلب الذكية"), table_cell_bold)
        ],
        [
            Paragraph(ar("إبراز أرقام السنوات والتواريخ بخط عريض مع زر كشف السياق التاريخي والأهمية المصيرية للحدث."), table_cell_style),
            Paragraph(ar("شارة ذهبية + صندوق إبراز التاريخ"), table_cell_style),
            Paragraph(ar("3. التواريخ والمحطات"), table_cell_bold)
        ],
        [
            Paragraph(ar("ملف تعريفي شامل للشخصية التاريخية يبرز الجنسية، والمنصب، وأهم القرارات والأحداث المرتبطة بها."), table_cell_style),
            Paragraph(ar("شارة بنفسجية + هالة صورة الشخصية"), table_cell_style),
            Paragraph(ar("4. الشخصيات البارزة"), table_cell_bold)
        ],
        [
            Paragraph(ar("تعريف دقيق للمصطلح الجغرافي أو التاريخي مع إبراز الكلمات المفتاحية الأساسية لضمان العلامة الكاملة."), table_cell_style),
            Paragraph(ar("شارة خضراء زمردية + أيقونة كتاب"), table_cell_style),
            Paragraph(ar("5. المصطلحات والمفاهيم"), table_cell_bold)
        ],
        [
            Paragraph(ar("حيل حفظ ذكية وصيغ اختصارات ورموز ذهنية لترسيخ المعلومات المعقدة في الذاكرة طويلة المدى."), table_cell_style),
            Paragraph(ar("شارة وردية + أيقونة مصباح الذاكرة"), table_cell_style),
            Paragraph(ar("6. كبسولة الذاكرة الفائقة"), table_cell_bold)
        ],
    ]
    cards_table = Table(cards_table_data, colWidths=[270, 130, 116])
    cards_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), primary_dark),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8FAFC")]),
    ]))
    story.append(cards_table)

    # Feature 2.3
    story.append(Spacer(1, 8))
    story.append(Paragraph(ar("2.3 خوارزمية ترتيب البطاقات حسب أولويات الحفظ (3-Tier Priority Algorithm)"), h2_style))
    story.append(Paragraph(
        ar("يقوم التطبيق بترتيب البطاقات ديناميكياً في 3 طبقات حسب درجة استيعاب الطالب السابقة لضمان أقصى كفاءة تعليمية:"),
        body_style
    ))
    story.append(Paragraph(ar("• <b>الطبقة 1 (أولوية قصوى - في المقدمة):</b> البطاقات الجديدة غير المراجعة + البطاقات المقيمة بـ <b>0% (لم أحفظ بعد / Not Yet)</b>. تظهر أولاً وتُخلط عشوائياً."), bullet_style))
    story.append(Paragraph(ar("• <b>الطبقة 2 (أولوية متوسطة - في الوسط):</b> البطاقات المقيمة بـ <b>50% (نصف حفظ / Partially)</b> لتثبيت استيعابها."), bullet_style))
    story.append(Paragraph(ar("• <b>الطبقة 3 (أولوية منخفضة - في النهاية):</b> البطاقات المقيمة بـ <b>100% (أتقنتُها / Mastered)</b> وتوضع في آخر القائمة حتى لا تشغل الطالب."), bullet_style))
    story.append(Paragraph(ar("• <b>إعادة الإدراج اللحظي:</b> عند تقييم بطاقة بـ 0%، يتم إدراجها فوراً بعد 4 بطاقات في نفس الجلسة لتكرارها اللحظي وتثبيتها."), bullet_style))
    story.append(Paragraph(ar("• <b>الحفظ المحلي المستمر:</b> تُحفظ تقييمات كل بطاقة محلياً في الذاكرة (StorageService) ليتذكر التطبيق مستوى الطالب بعد إعادة الفتح."), bullet_style))

    # Feature 2.4
    story.append(Spacer(1, 6))
    story.append(Paragraph(ar("2.4 نظام دعم وتغيير اللغات الشامل (العربية، الفرنسية، الإنجليزية)"), h2_style))
    story.append(Paragraph(
        ar("تم بناء نظام توطين وترجمة متكامل عبر LanguageProvider و AppTranslations:"),
        body_style
    ))
    story.append(Paragraph(ar("• <b>العربية (🇸🇦 - Arabic):</b> اللغة الافتراضية مع دعم كامل لاتجاه الشاشة من اليمين لليسار (RTL) وخط Tajawal."), bullet_style))
    story.append(Paragraph(ar("• <b>الفرنسية (🇫🇷 - Français):</b> اتجاه الشاشة من اليسار لليمين (LTR) وترجمة دقيقة لجميع المصطلحات."), bullet_style))
    story.append(Paragraph(ar("• <b>الإنجليزية (🇬🇧 - English):</b> اتجاه الشاشة من اليسار لليمين (LTR) لترجمة كاملة للمنصة."), bullet_style))
    story.append(Paragraph(ar("• <b>أزرار تبديل سريعة:</b> متوفرة في هيدر التلقيم، وصفحة الملف الشخصي، وشاشة تسجيل الدخول."), bullet_style))

    # Feature 2.5
    story.append(Spacer(1, 6))
    story.append(Paragraph(ar("2.5 التجاوب الكامل مع جميع الشاشات والأجهزة (flutter_screenutil_plus)"), h2_style))
    story.append(Paragraph(
        ar("تم تحويل كامل أبعاد ونصوص وهوامش التطبيق إلى وحدات متجاوبة (.w, .h, .r, .sp) اعتماداً على قياس تصميم قياسي Size(390, 844)، مما يضمن ملاءمة بصرية مثالية 100% وانعدام أي تجاوز في البكسلات (Zero Overflow) على مختلف أحجام الهواتف والأجهزة اللوحية."),
        body_style
    ))

    # Feature 2.6
    story.append(Spacer(1, 6))
    story.append(Paragraph(ar("2.6 العمل بدون إنترنت ومتانة الشبكة (Offline-First Architecture)"), h2_style))
    story.append(Paragraph(
        ar("صُمم التطبيق ليعمل بكفاءة عالية حتى في ظروف انقطاع الإنترنت أو بطئه:"),
        body_style
    ))
    story.append(Paragraph(ar("• <b>الدخول التجريبي الفوري (Offline Demo Mode):</b> زر مباشر للدخول واستعراض كافة البطاقات فوراً دون الحاجة لتشغيل خادم."), bullet_style))
    story.append(Paragraph(ar("• <b>طابور مزامنة المراجعات (OfflineSyncService):</b> حفظ تقييمات الطالب بدون نت ومزامنتها تلقائياً عند عودة الاتصال."), bullet_style))
    story.append(Paragraph(ar("• <b>ضبط IP الخادم من التطبيق:</b> نافذة مخصصة في شاشة الدخول لكتابة IP الحاسوب على شبكة الـ Wi-Fi بسهولة."), bullet_style))
    story.append(Paragraph(ar("• <b>مهلة اتصال 4 ثوانٍ (4s Timeout):</b> منع تعليق التطبيق عند عدم وصول الشبكة والتحول السلس للبيانات المحلية."), bullet_style))

    # Feature 2.7
    story.append(Spacer(1, 6))
    story.append(Paragraph(ar("2.7 مراجعة قفل الشاشة عند تشغيل الهاتف (LockscreenService)"), h2_style))
    story.append(Paragraph(
        ar("خدمة أندرويد ذكية تعمل في الخلفية لعرض بطاقة حفظ سريعة في كل مرة يفتح فيها الطالب شاشة هاتفه، مما يحول اللحظات الضائعة إلى مراجعات مثمرة."),
        body_style
    ))

    # ==================== 3. TECHNICAL ARCHITECTURE ====================
    story.append(Spacer(1, 8))
    story.append(Paragraph(ar("3. البنية البرمجية وهندسة حقن الاعتماديات (Riverpod DI Container)"), h1_style))
    
    arch_data = [
        [Paragraph(ar("المسؤولية البرمجية والمعمارية"), table_header_style), Paragraph(ar("معرف المزود (Provider)"), table_header_style), Paragraph(ar("الطبقة / الخدمة"), table_header_style)],
        [
            Paragraph(ar("إدارة حالة الواجهات التفاعلية، واللغة النشطة، واتجاه الشاشة (RTL/LTR)، ومصادقة المستخدم."), table_cell_style),
            Paragraph(ar("<code>tiktokFeedProvider</code><br/><code>languageProvider</code><br/><code>authProvider</code>"), table_cell_style),
            Paragraph(ar("<b>طبقة العرض (Presentation)</b>"), table_cell_bold)
        ],
        [
            Paragraph(ar("تنسيق جلب البطاقات، وتطبيق خوارزمية ترتيب الأولويات، والتعامل مع التخزين المؤقت والمزامنة."), table_cell_style),
            Paragraph(ar("<code>flashcardRepositoryProvider</code>"), table_cell_style),
            Paragraph(ar("<b>طبقة المستودع (Repository)</b>"), table_cell_bold)
        ],
        [
            Paragraph(ar("إدارة التخزين المؤقت المتسلسل للبيانات مع مدة صلاحية (TTL) وطابور مراجعات الأوفلاين."), table_cell_style),
            Paragraph(ar("<code>cacheManagerProvider</code><br/><code>offlineSyncServiceProvider</code>"), table_cell_style),
            Paragraph(ar("<b>محرك الكاش (Cache Engine)</b>"), table_cell_bold)
        ],
        [
            Paragraph(ar("إدارة الاتصال بـ API مع مهلة 4 ثوانٍ والتخزين المحلي الدائم عبر SharedPreferences."), table_cell_style),
            Paragraph(ar("<code>apiClientProvider</code><br/><code>storageServiceProvider</code>"), table_cell_style),
            Paragraph(ar("<b>طبقة الشبكة والتخزين</b>"), table_cell_bold)
        ],
    ]
    arch_table = Table(arch_data, colWidths=[240, 150, 126])
    arch_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#0F172A")),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8FAFC")]),
    ]))
    story.append(arch_table)

    # ==================== 4. SUMMARY TABLE & VERIFICATION ====================
    story.append(Spacer(1, 10))
    story.append(Paragraph(ar("4. ضمان الجودة والتحقق البرمجي النهائي"), h1_style))
    story.append(Paragraph(
        ar("تم فحص الكود بالكامل والتأكد من مطابقة أعلى معايير الجودة والاستقرار البرمجي:"),
        body_style
    ))
    story.append(Paragraph(ar("• <b>فحص الكود الثابت (Dart Static Analysis):</b> اجتياز أمر <code>dart analyze lib</code> بنجاح تام (0 أخطاء و 0 تحذيرات)."), bullet_style))
    story.append(Paragraph(ar("• <b>مستودع الباك إند:</b> <code>https://github.com/qcmlab/vixa-backend.git</code> (FastAPI, SM-2, JWT)."), bullet_style))
    story.append(Paragraph(ar("• <b>مستودع لوحة الإدارة:</b> <code>https://github.com/qcmlab/vixa-admin.git</code> (React, Tailwind, Multilingual)."), bullet_style))
    story.append(Paragraph(ar("• <b>مستودع تطبيق الموبايل:</b> <code>https://github.com/qcmlab/vixa-mobile.git</code> (Flutter, Riverpod, Offline-first)."), bullet_style))

    # Build Document
    doc.build(story, canvasmaker=ArabicNumberedCanvas)
    print(f"[OK] Successfully generated Arabic PDF: {os.path.abspath(filename)}")

if __name__ == '__main__':
    output_filename = "Hafedh_Mobile_App_Features_Specification_Arabic.pdf"
    if len(sys.argv) > 1:
        output_filename = sys.argv[1]
    build_arabic_pdf(output_filename)
