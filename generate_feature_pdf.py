import os
import sys
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super(NumberedCanvas, self).__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super(NumberedCanvas, self).showPage()
        super(NumberedCanvas, self).save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 9)
        self.setFillColor(colors.HexColor("#64748B"))
        
        # Header (pages > 1)
        if self._pageNumber > 1:
            self.drawString(54, 792 - 36, "Hafedh Mobile App — Complete Feature & Architecture Specification")
            self.setStrokeColor(colors.HexColor("#CBD5E1"))
            self.setLineWidth(0.5)
            self.line(54, 792 - 42, 612 - 54, 792 - 42)
            
        # Footer
        footer_text = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(612 - 54, 36, footer_text)
        self.drawString(54, 36, "CONFIDENTIAL & PROPRIETARY — HAFEDH EDTECH PLATFORM")
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.5)
        self.line(54, 46, 612 - 54, 46)
        self.restoreState()

def build_pdf(filename="Hafedh_Mobile_App_Features_Specification.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54,
    )

    styles = getSampleStyleSheet()
    
    # Custom styles
    primary_color = colors.HexColor("#0D9488")
    primary_dark = colors.HexColor("#0F766E")
    dark_bg = colors.HexColor("#0F172A")
    accent_gold = colors.HexColor("#F59E0B")
    accent_blue = colors.HexColor("#3B82F6")
    text_dark = colors.HexColor("#1E293B")
    text_muted = colors.HexColor("#64748B")
    
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=24,
        leading=28,
        textColor=primary_dark,
        alignment=TA_CENTER,
        spaceAfter=8,
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=12,
        leading=16,
        textColor=text_muted,
        alignment=TA_CENTER,
        spaceAfter=20,
    )
    
    h1_style = ParagraphStyle(
        'Heading1_Custom',
        fontName='Helvetica-Bold',
        fontSize=15,
        leading=19,
        textColor=primary_dark,
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True,
    )

    h2_style = ParagraphStyle(
        'Heading2_Custom',
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=15,
        textColor=colors.HexColor("#1E293B"),
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True,
    )

    body_style = ParagraphStyle(
        'Body_Custom',
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=text_dark,
        spaceAfter=6,
        alignment=TA_JUSTIFY,
    )

    bullet_style = ParagraphStyle(
        'Bullet_Custom',
        parent=body_style,
        leftIndent=15,
        firstLineIndent=-10,
        spaceAfter=4,
        alignment=TA_LEFT,
    )

    callout_style = ParagraphStyle(
        'Callout_Text',
        fontName='Helvetica',
        fontSize=9,
        leading=13,
        textColor=colors.HexColor("#0F766E"),
    )

    table_header_style = ParagraphStyle(
        'TableHeader',
        fontName='Helvetica-Bold',
        fontSize=9,
        leading=11,
        textColor=colors.white,
        alignment=TA_CENTER,
    )

    table_cell_style = ParagraphStyle(
        'TableCell',
        fontName='Helvetica',
        fontSize=8.5,
        leading=11,
        textColor=text_dark,
    )

    table_cell_bold = ParagraphStyle(
        'TableCellBold',
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=11,
        textColor=primary_dark,
    )

    story = []

    # ==================== COVER & HEADER ====================
    story.append(Spacer(1, 10))
    story.append(Paragraph("HAFEDH MOBILE APPLICATION", ParagraphStyle('SuperTitle', fontName='Helvetica-Bold', fontSize=10, leading=12, textColor=accent_gold, alignment=TA_CENTER, spaceAfter=4)))
    story.append(Paragraph("Complete Features & Technical Architecture Specification", title_style))
    story.append(Paragraph("A TikTok-Style Spaced Repetition Mobile Platform for Baccalaureate History & Geography", subtitle_style))
    
    story.append(HRFlowable(width="100%", thickness=1.5, color=primary_color, spaceBefore=0, spaceAfter=14))

    # Metadata Box Table
    meta_data = [
        [
            Paragraph("<b>Version:</b> 1.0.0 (Production)", table_cell_style),
            Paragraph("<b>Framework:</b> Flutter 3.x / Dart 3.x", table_cell_style),
            Paragraph("<b>State & DI:</b> Pure Riverpod 2.x", table_cell_style),
        ],
        [
            Paragraph("<b>Architecture:</b> Clean Architecture + Offline First", table_cell_style),
            Paragraph("<b>Supported Languages:</b> Arabic, French, English", table_cell_style),
            Paragraph("<b>Target Audience:</b> Baccalaureate Students", table_cell_style),
        ]
    ]
    meta_table = Table(meta_data, colWidths=[165, 170, 169])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F8FAFC")),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#E2E8F0")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 14))

    # ==================== 1. EXECUTIVE SUMMARY ====================
    story.append(Paragraph("1. Executive Summary & Core Philosophy", h1_style))
    story.append(Paragraph(
        "<b>Hafedh (حافظ)</b> is a high-retention mobile learning app designed to solve the cognitive fatigue associated with traditional rote memorization in the Algerian Baccalaureate curriculum (History & Geography). By marrying the highly engaging, addictive micro-interaction pattern of vertical swipe feeds (TikTok style) with scientifically proven cognitive spaced repetition (SuperMemo SM-2 algorithm), Hafedh empowers students to master complex dates, personalities, definitions, and concepts in effortless, daily bite-sized sessions.",
        body_style
    ))

    # Highlights Box
    box_data = [[
        Paragraph("<b>Key Architectural Pillars:</b><br/>"
                  "• <b>TikTok-Style Vertical Snapping:</b> Fast, addictive 60/120fps vertical feed designed for micro-learning.<br/>"
                  "• <b>6 Interactive Modalities:</b> QCM quizzes, 3D flip cards, date timelines, personality cards, definitions, memory advice.<br/>"
                  "• <b>3-Tier Priority Deck Re-Ordering:</b> Prioritizes unlearned and difficult cards with randomized internal ordering.<br/>"
                  "• <b>Offline-First Resilience:</b> Full offline caching, offline review queuing, and instant demo mode without server dependency.<br/>"
                  "• <b>Trilingual RTL/LTR Engine:</b> Complete localization in Arabic, French, and English with dynamic directionality.", callout_style)
    ]]
    box_table = Table(box_data, colWidths=[504])
    box_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F0FDFA")),
        ('BOX', (0, 0), (-1, -1), 1.2, primary_color),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('LEFTPADDING', (0, 0), (-1, -1), 12),
        ('RIGHTPADDING', (0, 0), (-1, -1), 12),
    ]))
    story.append(box_table)
    story.append(Spacer(1, 14))

    # ==================== 2. DETAILED FEATURE BREAKDOWN ====================
    story.append(Paragraph("2. Detailed Feature Breakdown", h1_style))
    
    # Feature 2.1
    story.append(Paragraph("2.1 Ultra-Smooth TikTok-Style Vertical Feed", h2_style))
    story.append(Paragraph(
        "The core learning experience takes place in a full-screen vertical <code>PageView.builder</code>. Designed to run at continuous 60fps/120fps on modern mobile displays:",
        body_style
    ))
    story.append(Paragraph("• <b>Allow Implicit Scrolling:</b> Pre-renders adjacent cards in memory, eliminating layout hitching and scroll stutters.", bullet_style))
    story.append(Paragraph("• <b>Zero-Rebuild Gesture Pipeline:</b> State listeners are isolated via Riverpod selectors, meaning swiping incurs zero tree rebuilds.", bullet_style))
    story.append(Paragraph("• <b>Repaint Boundaries:</b> Isolates GPU rasterization layers per card, preventing full-screen re-renders.", bullet_style))
    story.append(Paragraph("• <b>Auto-Advance Progression:</b> After submitting recall feedback, the feed smoothly animates to the next card after 650ms.", bullet_style))

    # Feature 2.2
    story.append(Spacer(1, 4))
    story.append(Paragraph("2.2 Six Distinct Interactive Card Modalities", h2_style))
    story.append(Paragraph(
        "To prevent cognitive monotony, the app renders 6 specialized card types dynamically matched to curriculum requirements:",
        body_style
    ))

    cards_table_data = [
        [Paragraph("Card Type", table_header_style), Paragraph("Visual Identity", table_header_style), Paragraph("Pedagogical Functionality & Interaction", table_header_style)],
        [
            Paragraph("<b>1. QCM Quiz</b>", table_cell_bold),
            Paragraph("Teal badge + 4 choice capsules", table_cell_style),
            Paragraph("Interactive multiple-choice questions with instant green/red validation and detailed pedagogical explanations.", table_cell_style)
        ],
        [
            Paragraph("<b>2. 3D Flip Card</b>", table_cell_bold),
            Paragraph("Blue badge + 3D Matrix4 Flip", table_cell_style),
            Paragraph("Realistic 3D flipping animation revealing standard Baccalaureate model answers and memory keys.", table_cell_style)
        ],
        [
            Paragraph("<b>3. Historical Dates</b>", table_cell_bold),
            Paragraph("Gold badge + Date highlight", table_cell_style),
            Paragraph("Large prominent date numerals with interactive 'Reveal Historical Context' button and timeline clues.", table_cell_style)
        ],
        [
            Paragraph("<b>4. Personality Card</b>", table_cell_bold),
            Paragraph("Purple badge + Avatar halo", table_cell_style),
            Paragraph("Biographical profile of key leaders/figures highlighting nationalities, key decisions, and historical roles.", table_cell_style)
        ],
        [
            Paragraph("<b>5. Concept & Term</b>", table_cell_bold),
            Paragraph("Emerald badge + Book icon", table_cell_style),
            Paragraph("Glossary definition card highlighting core keywords and exam criteria for accurate memorization.", table_cell_style)
        ],
        [
            Paragraph("<b>6. Memory Advice</b>", table_cell_bold),
            Paragraph("Rose badge + Bulb icon", table_cell_style),
            Paragraph("Mnemonic formulas, acronyms, and cognitive memory capsules designed to anchor hard-to-remember facts.", table_cell_style)
        ],
    ]
    cards_table = Table(cards_table_data, colWidths=[100, 130, 274])
    cards_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), primary_dark),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8FAFC")]),
    ]))
    story.append(cards_table)

    # Feature 2.3
    story.append(Spacer(1, 10))
    story.append(Paragraph("2.3 3-Tier Memorization Priority Deck Re-Ordering Algorithm", h2_style))
    story.append(Paragraph(
        "The deck dynamically arranges learning materials into 3 priority tiers based on the student's historical recall feedback:",
        body_style
    ))
    story.append(Paragraph("• <b>Tier 1 (Top Priority):</b> Unreviewed cards + cards marked <b>0% (لم أحفظ / Not Yet)</b>. These appear first and are shuffled randomly for fresh variety.", bullet_style))
    story.append(Paragraph("• <b>Tier 2 (Middle Priority):</b> Cards marked <b>50% (نصف حفظ / Partially)</b>. Placed in the middle queue for stabilization.", bullet_style))
    story.append(Paragraph("• <b>Tier 3 (Low Priority):</b> Cards marked <b>100% (أتقنتُها / Mastered)</b>. Placed at the end of the session to avoid cluttering new material.", bullet_style))
    story.append(Paragraph("• <b>Real-Time Re-Insertion:</b> Marking a card 0% immediately re-inserts it 4 slots ahead in the active session for instant cognitive reinforcement.", bullet_style))
    story.append(Paragraph("• <b>Persistent Recall Memory:</b> All ratings are saved to local persistent storage (<code>StorageService</code>), maintaining the student's prioritized order across app restarts.", bullet_style))

    # Feature 2.4
    story.append(Spacer(1, 6))
    story.append(Paragraph("2.4 Comprehensive Multilingual Support (AR, FR, EN)", h2_style))
    story.append(Paragraph(
        "Full localization architecture powered by <code>LanguageProvider</code> and <code>AppTranslations</code>:",
        body_style
    ))
    story.append(Paragraph("• <b>Arabic (العربية - 🇸🇦):</b> Default language with full Right-to-Left (RTL) layout and Tajawal typography.", bullet_style))
    story.append(Paragraph("• <b>French (Français - 🇫🇷):</b> Left-to-Right (LTR) layout with native French terminology.", bullet_style))
    story.append(Paragraph("• <b>English (English - 🇬🇧):</b> Left-to-Right (LTR) layout with modern educational phrasing.", bullet_style))
    story.append(Paragraph("• <b>Instant Switcher Touchpoints:</b> Available from the top feed header, user profile screen, and login screen.", bullet_style))

    # Feature 2.5
    story.append(Spacer(1, 6))
    story.append(Paragraph("2.5 Pixel-Perfect Responsiveness (`flutter_screenutil_plus`)", h2_style))
    story.append(Paragraph(
        "All visual components, paddings, icon bounds, and typography are mathematically scaled using <code>flutter_screenutil_plus</code> based on standard design viewport <code>Size(390, 844)</code> with <code>.w</code>, <code>.h</code>, <code>.r</code>, and <code>.sp</code> units. This guarantees zero visual clipping or overflows across all Android and iOS form factors.",
        body_style
    ))

    # Feature 2.6
    story.append(Spacer(1, 6))
    story.append(Paragraph("2.6 Offline-First Architecture & Network Resilience", h2_style))
    story.append(Paragraph(
        "Engineered for students in areas with unreliable internet connectivity:",
        body_style
    ))
    story.append(Paragraph("• <b>Instant Offline Demo Mode:</b> One-tap entry on the login screen allowing instant study with zero server connection.", bullet_style))
    story.append(Paragraph("• <b>Offline Review Queuing:</b> Offline card ratings are queued in <code>OfflineSyncService</code> and synced automatically when network returns.", bullet_style))
    story.append(Paragraph("• <b>Dynamic Server IP Configuration:</b> Dedicated in-app dialog allowing physical mobile devices to connect to local development IPs.", bullet_style))
    story.append(Paragraph("• <b>4-Second HTTP Timeout:</b> Prevents infinite network hanging on physical devices, falling back gracefully to cached datasets.", bullet_style))

    # Feature 2.7
    story.append(Spacer(1, 6))
    story.append(Paragraph("2.7 Lock-Screen Study Mode (`LockscreenService`)", h2_style))
    story.append(Paragraph(
        "An innovative background Android service that automatically prompts a rapid flashcard whenever the student wakes or unlocks their phone, converting passive screen unlocks into high-retention study moments.",
        body_style
    ))

    # ==================== 3. TECHNICAL ARCHITECTURE ====================
    story.append(Spacer(1, 10))
    story.append(Paragraph("3. Technical Architecture & Dependency Injection", h1_style))
    
    arch_data = [
        [Paragraph("Layer / Service", table_header_style), Paragraph("Provider Identifier", table_header_style), Paragraph("Architectural Responsibility", table_header_style)],
        [
            Paragraph("<b>Presentation Layer</b>", table_cell_bold),
            Paragraph("<code>tiktokFeedProvider</code><br/><code>languageProvider</code><br/><code>authProvider</code>", table_cell_style),
            Paragraph("Riverpod StateNotifiers managing reactive UI state, theme, directionality, and localized viewports.", table_cell_style)
        ],
        [
            Paragraph("<b>Domain & Repository</b>", table_cell_bold),
            Paragraph("<code>flashcardRepositoryProvider</code>", table_cell_style),
            Paragraph("Orchestrates offline caching, network fetches, priority deck shuffling, and offline review synchronization.", table_cell_style)
        ],
        [
            Paragraph("<b>Cache Engine</b>", table_cell_bold),
            Paragraph("<code>cacheManagerProvider</code><br/><code>offlineSyncServiceProvider</code>", table_cell_style),
            Paragraph("Manages serialized JSON cache with TTL invalidation and persistent review synchronization queues.", table_cell_style)
        ],
        [
            Paragraph("<b>Network & Storage</b>", table_cell_bold),
            Paragraph("<code>apiClientProvider</code><br/><code>storageServiceProvider</code>", table_cell_style),
            Paragraph("Handles HTTP communication with 4s timeouts, auth headers, and persistent SharedPreferences storage.", table_cell_style)
        ],
    ]
    arch_table = Table(arch_data, colWidths=[120, 150, 234])
    arch_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#0F172A")),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8FAFC")]),
    ]))
    story.append(arch_table)

    # ==================== 4. SUMMARY TABLE & VERIFICATION ====================
    story.append(Spacer(1, 14))
    story.append(Paragraph("4. Quality Assurance & System Verification", h1_style))
    story.append(Paragraph(
        "The codebase adheres to rigorous clean code standards, validated through static analysis and version-controlled Git synchronization:",
        body_style
    ))
    story.append(Paragraph("• <b>Dart Static Analysis:</b> <code>dart analyze lib</code> completed with <b>0 errors and 0 warnings</b>.", bullet_style))
    story.append(Paragraph("• <b>Backend Repository:</b> <code>https://github.com/qcmlab/vixa-backend.git</code> (FastAPI, SM-2, JWT Auth).", bullet_style))
    story.append(Paragraph("• <b>Admin Dashboard:</b> <code>https://github.com/qcmlab/vixa-admin.git</code> (React, Tailwind, Multilingual).", bullet_style))
    story.append(Paragraph("• <b>Mobile Repository:</b> <code>https://github.com/qcmlab/vixa-mobile.git</code> (Flutter, Riverpod, Offline-first).", bullet_style))

    # Build Document
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"[OK] Successfully generated PDF: {os.path.abspath(filename)}")

if __name__ == '__main__':
    output_filename = "Hafedh_Mobile_App_Features_Specification.pdf"
    if len(sys.argv) > 1:
        output_filename = sys.argv[1]
    build_pdf(output_filename)
