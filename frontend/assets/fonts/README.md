# Кастомные шрифты

Эта директория содержит шрифты YandexSansText для приложения R&D Planner.

## Установленные шрифты

В приложении используется шрифт **YandexSansText** со следующими вариантами:

1. **YandexSansText-Thin.ttf** - тонкий шрифт (weight: 100)
2. **YandexSansText-Light.ttf** - легкий шрифт (weight: 300)
3. **YandexSansText-Regular.ttf** - обычный шрифт (weight: 400)
4. **YandexSansText-Medium.ttf** - средний шрифт (weight: 500)
5. **YandexSansText-Bold.ttf** - жирный шрифт (weight: 700)
6. **YandexSansText-RegularItalic.ttf** - курсив (weight: 400, style: italic)

## Как добавить шрифт

1. Скопируйте файлы шрифтов в эту директорию
2. Убедитесь, что имена файлов соответствуют указанным в `pubspec.yaml`
3. Запустите `flutter pub get` для обновления зависимостей
4. Перезапустите приложение

## Использование в коде

```dart
// Использование готовых стилей YandexSansText
Text('Большой заголовок', style: ThemeService.displayStyle)
Text('Заголовок', style: ThemeService.headingStyle)
Text('Подзаголовок', style: ThemeService.subheadingStyle)
Text('Основной текст', style: ThemeService.bodyStyle)
Text('Средний текст', style: ThemeService.mediumStyle)
Text('Мелкий текст', style: ThemeService.captionStyle)
Text('Тонкий текст', style: ThemeService.thinStyle)
Text('Курсив', style: ThemeService.italicStyle)
Text('Кнопка', style: ThemeService.buttonStyle)

// Создание кастомного стиля
Text('Кастомный текст', style: ThemeService.getTextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w500,
  color: Colors.blue,
))
```

## Примечания

- Шрифт будет применен ко всему приложению автоматически через глобальную тему
- Для изменения семейства шрифта отредактируйте `_fontFamily` в `ThemeService`
- Убедитесь, что файлы шрифтов имеют правильные лицензии для коммерческого использования
