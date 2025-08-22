#!/bin/bash

# iOS 아이콘 디렉토리
ICON_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

echo "iOS 아이콘의 알파 채널을 제거하는 중..."

# 모든 아이콘 파일 처리
for icon in "$ICON_DIR"/Icon-App-*.png; do
    if [ -f "$icon" ]; then
        filename=$(basename "$icon")
        echo "처리 중: $filename"
        
        # 임시 파일로 변환 (알파 채널 제거)
        sips -s format png -s formatOptions default "$icon" --out "${icon}.tmp" 2>/dev/null
        
        # 원본 파일 교체
        mv "${icon}.tmp" "$icon"
    fi
done

# 특히 중요한 1024x1024 아이콘 확인
MAIN_ICON="$ICON_DIR/Icon-App-1024x1024@1x.png"
if [ -f "$MAIN_ICON" ]; then
    echo ""
    echo "1024x1024 아이콘 확인 중..."
    sips -g format -g hasAlpha "$MAIN_ICON"
fi

echo ""
echo "완료! 모든 아이콘이 처리되었습니다."