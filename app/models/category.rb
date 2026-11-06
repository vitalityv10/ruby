class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # slug генерується з назви (транслітерація кирилиці), якщо адмін його не вказав
  before_validation { self.slug = self.class.slugify(name) if slug.blank? && name.present? }

  TRANSLIT = {
    "а"=>"a","б"=>"b","в"=>"v","г"=>"h","ґ"=>"g","д"=>"d","е"=>"e","є"=>"ye","ж"=>"zh","з"=>"z","и"=>"y",
    "і"=>"i","ї"=>"yi","й"=>"y","к"=>"k","л"=>"l","м"=>"m","н"=>"n","о"=>"o","п"=>"p","р"=>"r","с"=>"s",
    "т"=>"t","у"=>"u","ф"=>"f","х"=>"kh","ц"=>"ts","ч"=>"ch","ш"=>"sh","щ"=>"shch","ь"=>"","ю"=>"yu",
    "я"=>"ya","'"=>"","’"=>"","ʼ"=>""
  }.freeze

  def self.slugify(text)
    text.to_s.downcase.chars.map { |c| TRANSLIT.fetch(c, c) }.join.parameterize
  end

  scope :ordered, -> { order(:name) }
end
