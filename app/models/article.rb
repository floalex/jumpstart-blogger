class Article < ActiveRecord::Base
  validates :title, :presence => true, :uniqueness => true
  validates :body, :presence => true
  
  belongs_to :author
  has_many :comments
  has_many :taggings
  has_many :tags, through: :taggings
  
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png"]
  
  # Alternative: define to_s method with name under tag.rb
  def tag_list
    self.tags.collect do |tag|
      tag.name
    end.join(", ")
  end
  
  def tag_list=(tags_string)
    tag_names = tags_string.split(",").collect{|s| s.strip.downcase}.uniq
    new_or_found_tags = tag_names.collect{ |name| Tag.find_or_create_by(name: name) }
    self.tags = new_or_found_tags
  end
  
  def self.most_popular
    all.sort_by{|a| a.comments.count }.last
  end

  def self.random
    order('RANDOM()').limit(1).first
  end

  def self.valid_ids
    Article.select(:id).collect{|a| a.id}
  end

  def self.search_by_tag_name(tag_name)
    if tag_name.blank?
      [Article.all, nil]
    else
      tag = Tag.find_by_name(tag_name)
      tag ? [tag.articles, tag] : [[], nil]
    end
  end

  def self.for_dashboard
    order('created_at DESC').limit(5)
  end

  def word_count
    body.split.count
  end

  def self.total_word_count
    all.inject(0) {|total, a| total += a.word_count }
  end

  def self.generate_samples(quantity = 1000)
    tags = Tag.all
    quantity.times do
      article = Fabricate(:article)
      article.created_at = article.created_at - (rand(300) + 100).hours
      article.tags = tags.sort_by{ rand }.take(3)
      article.save
      rand(2..6).times do
        Fabricate(:comment, :article => article, :created_at => article.created_at + rand(100).hours)
      end
      yield if block_given?
    end
  end
  
  #Track the number of times an article has been viewed
  def view_count
    Article.increment_counter(:views, self.id)
  end
end
