# Ідемпотентне наповнення каталогу. Запуск: bin/rails db:seed
categories = {
  "rods"  => ["Вудилища та спінінги", "Спінінги, фідери та коропові вудилища"],
  "reels" => ["Котушки", "Безінерційні та мультиплікаторні котушки"],
  "lures" => ["Приманки та воблери", "Воблери, блешні, силікон"],
  "lines" => ["Волосінь та шнури", "Монофільні волосіні та плетені шнури"],
  "gear"  => ["Екіпірування та аксесуари", "Одяг, сумки, підсаки, інструменти"]
}.to_h do |slug, (name, desc)|
  c = Category.find_or_initialize_by(slug: slug)
  c.update!(name: name, description: desc)
  [slug, c]
end

products = [
  ["rods", "Спінінг Favorite White Bird 2.4 м 5-21 г", 2150, 8, "ROD-001"],
  ["rods", "Спінінг Daiwa Ninja X 2.7 м 10-30 г", 2890, 5, "ROD-002"],
  ["rods", "Фідер Brain Apache Feeder 3.6 м", 2450, 4, "ROD-003"],
  ["reels", "Котушка Shimano Catana 2500", 1390, 12, "REL-001"],
  ["reels", "Котушка Daiwa Ninja LT 3000", 2750, 6, "REL-002"],
  ["reels", "Котушка Ryobi Slam 2000", 980, 0, "REL-003"],
  ["lures", "Воблер Kosadaka Mirage 90F", 185, 40, "LUR-001"],
  ["lures", "Блешня Select Spoon 12 г", 65, 100, "LUR-002"],
  ["lures", "Силіконова приманка Relax Kopyto 3\"", 95, 60, "LUR-003"],
  ["lines", "Шнур плетений Select Basic PE 0.12 мм 150 м", 320, 25, "LIN-001"],
  ["lines", "Волосінь Climax Cult Carp 0.30 мм 300 м", 275, 18, "LIN-002"],
  ["gear", "Підсак складний Ranger 60 см", 640, 9, "GEA-001"],
  ["gear", "Сумка рибальська Select Tackle Bag", 890, 7, "GEA-002"],
  ["gear", "Жилет рибальський Norfin Vest", 1450, 3, "GEA-003"]
]

products.each do |slug, name, price, stock, sku|
  p = Product.find_or_initialize_by(sku: sku)
  p.update!(category: categories[slug], name: name, price: price, stock_quantity: stock,
            description: "#{name} — якісне спорядження для успішної риболовлі від магазину «Рибальський дворик».")
end

puts "Категорій: #{Category.count}, товарів: #{Product.count}"

user = User.find_by(email: "vintoniakvitalij74@gmail.com")
user&.update!(admin: true)
