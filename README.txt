Main features.

# Админка 
  # Раздел страницы, 3 статические страницы ("Контакты", "О нас", "Услуги") с полями title и content
  # Раздел "Коллекции", поля title и files (набор картинок)
  # Раздел "Магазин", поля title, price (int), category-title (раздел), files (набор картинок), description (текст)
  # Раздел "Заказы", поля items (alist id и количества элементов заказов), notes (текст), completed (bool)
# Главный вид 
  # Статические страницы ("Контакты", "О нас", "Услуги")
  # Коллекции 
    # Отображение всех картинок для выбранной коллекции
  # Раздел Shop
    # Страница списка, отображаются элементы из выбранной категории (thumbnail и название)
    # Страница просмотра элемента Shop Item, отображаются картинки в виде галереи-слайдера если есть, цена, описание, кнопка "купить"
  # Страница Shopping cart
    # увеличение/уменьшение количества элементов
    # удаление элементов
    # подтверждение заказа
# Для всех картинок делаются thumbnails в пределах 213x213 
