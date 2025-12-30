#!/usr/bin/env python3
"""
Filter and categorize quotes for HopeCore app.
Takes ~500K quotes and filters to ~5K high-quality hopecore quotes.

Categories (quotes can have multiple):
- Agency: Taking action, control, making choices
- Possibility: Hope, dreams, future potential
- Resilience: Bouncing back, overcoming adversity
- Growth: Learning, transformation, becoming
- Self-Worth: Identity, confidence, self-belief
- Connection: Community, relationships, kindness
- Mindfulness: Presence, peace, acceptance
- Purpose: Meaning, direction, passion
"""

import csv
import json
import uuid
import re
from collections import defaultdict

# Configuration
INPUT_FILE = "/Users/reedrawlings/Downloads/quotes.csv"
OUTPUT_FILE = "/Users/reedrawlings/Desktop/HopeCore/HopeCore/Resources/quotes_filtered.json"
TARGET_COUNT = 5000
MAX_LENGTH = 280
MIN_LENGTH = 20

# Category definitions with keywords to match
# Each category has: tag keywords (from CSV tags) and text keywords (from quote text)
CATEGORIES = {
    "Agency": {
        "tag_keywords": [
            "action", "courage", "strength", "determination", "choice", "decision",
            "control", "responsibility", "discipline", "power", "will", "willpower",
            "effort", "initiative", "proactive", "bold", "brave", "fearless",
            "independent", "self-reliance", "autonomy"
        ],
        "text_keywords": [
            "take action", "make the choice", "in your hands", "up to you",
            "decide", "choose", "courage", "brave", "bold", "dare", "risk",
            "step forward", "take the leap", "seize", "grab", "own your",
            "take control", "be the change", "make it happen", "do it",
            "start now", "begin today", "take the first step", "just start"
        ]
    },
    "Possibility": {
        "tag_keywords": [
            "hope", "dreams", "future", "potential", "opportunity", "possibilities",
            "imagination", "vision", "faith", "optimism", "aspiration", "ambition",
            "new-beginning", "tomorrow", "miracle", "wonder", "believe"
        ],
        "text_keywords": [
            "hope", "dream", "possible", "possibility", "potential", "future",
            "tomorrow", "one day", "imagine", "vision", "believe", "faith",
            "anything is possible", "never give up", "keep hoping", "bright future",
            "new beginning", "fresh start", "opportunity", "door opens", "window opens",
            "what if", "could be", "might be", "can be", "will be"
        ]
    },
    "Resilience": {
        "tag_keywords": [
            "resilience", "perseverance", "persistence", "endurance", "tenacity",
            "strength", "overcome", "adversity", "struggle", "survival", "fighter",
            "bounce-back", "never-give-up", "determination", "grit", "tough"
        ],
        "text_keywords": [
            "resilience", "resilient", "overcome", "rise again", "get back up",
            "fall down", "stand up", "keep going", "don't give up", "never quit",
            "persist", "endure", "survive", "through the storm", "after the rain",
            "rock bottom", "darkest hour", "tough times", "hard times", "struggle",
            "fight", "warrior", "soldier on", "carry on", "bounce back", "rise up"
        ]
    },
    "Growth": {
        "tag_keywords": [
            "growth", "learning", "education", "wisdom", "knowledge", "development",
            "transformation", "change", "evolve", "improve", "progress", "journey",
            "experience", "lessons", "mistakes", "failure", "becoming"
        ],
        "text_keywords": [
            "grow", "growth", "learn", "learning", "lesson", "teach", "taught",
            "change", "transform", "evolve", "become", "becoming", "improve",
            "better version", "work in progress", "journey", "process", "path",
            "mistake", "failure", "experience", "wisdom", "understand", "realize",
            "discover", "evolving", "developing", "maturing", "unfolding"
        ]
    },
    "Self-Worth": {
        "tag_keywords": [
            "self-love", "self-worth", "self-esteem", "confidence", "self-confidence",
            "self-belief", "identity", "self-acceptance", "self-respect", "dignity",
            "worthy", "enough", "self-care", "self-compassion", "authenticity"
        ],
        "text_keywords": [
            "worth", "worthy", "enough", "deserve", "self-love", "love yourself",
            "believe in yourself", "you are", "you're enough", "accept yourself",
            "be yourself", "authentic", "true to", "own skin", "who you are",
            "value yourself", "respect yourself", "confidence", "confident",
            "beautiful", "unique", "special", "matter", "important", "valued"
        ]
    },
    "Connection": {
        "tag_keywords": [
            "friendship", "community", "together", "unity", "kindness", "compassion",
            "empathy", "humanity", "support", "help", "love", "caring", "giving",
            "relationship", "bond", "trust", "loyalty", "belonging"
        ],
        "text_keywords": [
            "together", "community", "friend", "friendship", "connection", "connect",
            "support", "help", "kindness", "kind", "compassion", "empathy",
            "humanity", "human", "people", "others", "each other", "one another",
            "belong", "belonging", "trust", "loyal", "bond", "relationship",
            "not alone", "with you", "for you", "beside you", "lift each other"
        ]
    },
    "Mindfulness": {
        "tag_keywords": [
            "mindfulness", "present", "presence", "peace", "calm", "serenity",
            "acceptance", "gratitude", "grateful", "meditation", "awareness",
            "stillness", "quiet", "inner-peace", "zen", "moment", "now"
        ],
        "text_keywords": [
            "present", "moment", "now", "today", "here", "peace", "peaceful",
            "calm", "quiet", "still", "stillness", "breathe", "breath", "pause",
            "slow down", "let go", "accept", "acceptance", "grateful", "gratitude",
            "appreciate", "mindful", "aware", "awareness", "inner peace", "at peace"
        ]
    },
    "Purpose": {
        "tag_keywords": [
            "purpose", "meaning", "passion", "calling", "mission", "destiny",
            "life-purpose", "direction", "goal", "vision", "legacy", "contribution",
            "impact", "difference", "fulfillment", "vocation"
        ],
        "text_keywords": [
            "purpose", "meaning", "meaningful", "passion", "calling", "mission",
            "destiny", "meant to", "born to", "reason", "why", "direction",
            "goal", "vision", "legacy", "impact", "difference", "contribute",
            "matter", "count", "fulfill", "fulfillment", "life's work", "path"
        ]
    }
}

# Tags that indicate the quote is likely NOT hopecore material
EXCLUDE_TAGS = [
    "romance", "romantic", "sex", "erotic", "erotica", "lust", "sensual",
    "marriage", "wedding", "boyfriend", "girlfriend", "dating", "flirt",
    "heartbreak", "breakup", "divorce", "cheating", "affair",
    "death", "suicide", "murder", "kill", "violence", "war", "weapon",
    "politics", "political", "religion", "religious", "atheism",
    "humor", "funny", "joke", "sarcasm", "sarcastic", "irony", "ironic"
]

# Priority tags that indicate high-quality motivational content
PRIORITY_TAGS = [
    "inspirational", "motivational", "hope", "strength", "courage",
    "wisdom", "life-lessons", "perseverance", "resilience", "self-improvement",
    "personal-growth", "empowerment", "positive", "uplifting"
]


def clean_quote(text):
    """Clean up quote text."""
    if not text:
        return ""
    # Remove extra whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    # Remove leading/trailing quotes
    text = text.strip('"\'""''')
    return text


def get_tags(category_str):
    """Parse comma-separated tags."""
    if not category_str:
        return []
    return [tag.strip().lower().replace(' ', '-') for tag in category_str.split(',')]


def categorize_quote(text, tags):
    """
    Determine categories for a quote based on tags and text content.
    Returns list of matching categories.
    """
    text_lower = text.lower()
    matched_categories = []

    for category, keywords in CATEGORIES.items():
        score = 0

        # Check tag keywords
        for tag in tags:
            for kw in keywords["tag_keywords"]:
                if kw in tag:
                    score += 2
                    break

        # Check text keywords
        for kw in keywords["text_keywords"]:
            if kw in text_lower:
                score += 1

        # Threshold for inclusion
        if score >= 2:
            matched_categories.append((category, score))

    # Sort by score and return category names
    matched_categories.sort(key=lambda x: x[1], reverse=True)

    # Return top 3 categories max
    categories = [cat for cat, score in matched_categories[:3]]

    # Default to Possibility if no matches
    if not categories:
        categories = ["Possibility"]

    return categories


def should_exclude(text, tags):
    """Check if quote should be excluded."""
    text_lower = text.lower()

    # Exclude based on tags
    for tag in tags:
        for exclude in EXCLUDE_TAGS:
            if exclude in tag:
                return True

    # Exclude quotes that are questions without answers
    if text.strip().endswith('?') and len(text) < 50:
        return True

    # Exclude quotes with too many pronouns suggesting dialogue
    if text.count('"') > 2 or text.count("'") > 4:
        return True

    return False


def has_priority_tag(tags):
    """Check if quote has a priority tag."""
    for tag in tags:
        for priority in PRIORITY_TAGS:
            if priority in tag:
                return True
    return False


def score_quote(quote, tags, author, categories):
    """Score quote quality (higher = better)."""
    score = 0

    # Length scoring (prefer 50-180 chars)
    length = len(quote)
    if 60 <= length <= 150:
        score += 4
    elif 40 <= length <= 180:
        score += 3
    elif 30 <= length <= 220:
        score += 2
    else:
        score += 1

    # Has known author (not "Unknown" or empty)
    if author and author.strip() and author.lower() not in ["unknown", "anonymous", ""]:
        score += 2

    # Priority tags bonus
    if has_priority_tag(tags):
        score += 3

    # Multiple relevant categories = more versatile quote
    if len(categories) >= 2:
        score += 2
    if len(categories) >= 3:
        score += 1

    # Penalize if starts with "I" (often too personal/specific)
    if quote.strip().startswith("I ") or quote.strip().startswith("I'"):
        score -= 1

    # Bonus for universal statements
    universal_starters = ["the", "a ", "life", "success", "happiness", "you", "we", "every"]
    if any(quote.lower().strip().startswith(s) for s in universal_starters):
        score += 1

    return score


def main():
    print(f"Reading quotes from {INPUT_FILE}...")
    print(f"Target: {TARGET_COUNT} quotes\n")

    quotes = []
    seen_texts = set()  # For deduplication
    total_read = 0
    excluded_count = 0

    with open(INPUT_FILE, 'r', encoding='utf-8', errors='ignore') as f:
        reader = csv.DictReader(f)

        for row in reader:
            total_read += 1

            quote_text = clean_quote(row.get('quote', ''))
            author = row.get('author', '').strip()
            tags = get_tags(row.get('category', ''))

            # Skip if too short or too long
            if len(quote_text) < MIN_LENGTH or len(quote_text) > MAX_LENGTH:
                continue

            # Skip duplicates (normalize for comparison)
            text_normalized = re.sub(r'[^\w\s]', '', quote_text.lower())
            if text_normalized in seen_texts:
                continue
            seen_texts.add(text_normalized)

            # Skip excluded content
            if should_exclude(quote_text, tags):
                excluded_count += 1
                continue

            # Categorize
            categories = categorize_quote(quote_text, tags)

            # Score
            score = score_quote(quote_text, tags, author, categories)

            quotes.append({
                'text': quote_text,
                'author': author,
                'categories': categories,
                'score': score,
                'original_tags': tags
            })

            # Progress indicator
            if total_read % 100000 == 0:
                print(f"  Processed {total_read:,} quotes...")

    print(f"\nRead {total_read:,} total quotes")
    print(f"Excluded {excluded_count:,} quotes")
    print(f"Found {len(quotes):,} candidate quotes after filtering")

    # Sort by score
    quotes.sort(key=lambda x: x['score'], reverse=True)

    # Category distribution before selection
    category_counts = defaultdict(int)
    for q in quotes:
        for cat in q['categories']:
            category_counts[cat] += 1

    print("\nCategory distribution (before selection):")
    for cat in CATEGORIES.keys():
        print(f"  {cat}: {category_counts[cat]:,}")

    # Select top quotes, ensuring category balance
    # First, ensure we have at least 400 quotes per category
    selected = []
    selected_ids = set()

    min_per_category = TARGET_COUNT // len(CATEGORIES)  # ~625 per category

    for category in CATEGORIES.keys():
        # Get quotes that have this category as primary (first in list)
        cat_quotes = [q for q in quotes if q['categories'][0] == category and id(q) not in selected_ids]
        cat_quotes.sort(key=lambda x: x['score'], reverse=True)

        to_select = cat_quotes[:min_per_category]
        for q in to_select:
            selected.append(q)
            selected_ids.add(id(q))

    # Fill remaining with highest scored
    remaining = TARGET_COUNT - len(selected)
    remaining_quotes = [q for q in quotes if id(q) not in selected_ids]
    remaining_quotes.sort(key=lambda x: x['score'], reverse=True)
    selected.extend(remaining_quotes[:remaining])

    print(f"\nSelected {len(selected):,} quotes")

    # Final category distribution
    final_counts = defaultdict(int)
    for q in selected:
        for cat in q['categories']:
            final_counts[cat] += 1

    print("\nFinal category distribution:")
    for cat in CATEGORIES.keys():
        print(f"  {cat}: {final_counts[cat]:,}")

    # Convert to app format
    output = []
    for q in selected:
        output.append({
            "id": str(uuid.uuid4()),
            "text": q['text'],
            "categories": q['categories'],
            "author": q['author'] if q['author'] and q['author'].lower() not in ["unknown", "anonymous"] else None,
            "trackType": "hope",
            "presentationMode": "textOverlay"
        })

    # Shuffle to mix categories
    import random
    random.shuffle(output)

    # Write output
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Wrote {len(output):,} quotes to {OUTPUT_FILE}")

    # Show sample quotes from each category
    print("\n" + "="*60)
    print("SAMPLE QUOTES BY CATEGORY")
    print("="*60)

    for cat in CATEGORIES.keys():
        cat_quotes = [q for q in selected if cat in q['categories']][:2]
        print(f"\n📌 {cat}:")
        for q in cat_quotes:
            author_str = f" — {q['author']}" if q['author'] else ""
            print(f"   \"{q['text'][:100]}...\"{author_str}")
            print(f"   Categories: {', '.join(q['categories'])}")


if __name__ == "__main__":
    main()
