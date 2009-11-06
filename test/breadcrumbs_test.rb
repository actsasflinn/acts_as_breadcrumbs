require File.join(File.dirname(__FILE__), 'test_helper')

class Node < ActiveRecord::Base
  acts_as_nested_set  # need this
  acts_as_breadcrumbs
end

class Location < ActiveRecord::Base
  acts_as_nested_set  # need this
  acts_as_breadcrumbs :location_string
end

class Soldier < ActiveRecord::Base
  acts_as_nested_set  # need this
  acts_as_breadcrumbs :chain_o_command, :separator => " > ", :include_root => false
end

class WebPage < ActiveRecord::Base
  acts_as_nested_set  # need this
  acts_as_breadcrumbs :url, :basename => :slug, :separator => "/"
  acts_as_breadcrumbs :basename => :title, :separator => "&nbsp;&gt;&nbsp;"

  def slug
    title.parameterize.to_s
  end
end

class BreadcrumbsTest < Test::Unit::TestCase
  def test_no_options
    root = Node.create(:name => "Root")
    child1 = root.children.create(:name => "Level 1")
    child2 = child1.children.create(:name => "Level 2")
    root2 = Node.create(:name => "Root 2")

    assert_equal "Root:Level 1:Level 2", child2.breadcrumbs    
  end

  def test_alternate_attribute
    root = Location.create(:name => "HQ")
    child1 = root.children.create(:name => "FL01")
    child2 = child1.children.create(:name => "RM03")

    assert_equal "HQ:FL01:RM03", child2.location_string
  end

  def test_basename
    root = WebPage.create(:title => "Foo")
    child1 = root.children.create(:title => "Bar")
    child2 = child1.children.create(:title => "Baz")

    assert_equal "foo/bar/baz", child2.url
  end

  def test_separator
    root = Soldier.create(:name => "President Paul")
    child1 = root.children.create(:name => "General Hailstone")
    child2 = child1.children.create(:name => "Colonel Stanley")
    child3 = child2.children.create(:name => "LTC Mueller")

    assert_equal "General Hailstone > Colonel Stanley > LTC Mueller", child3.chain_o_command
  end

  def test_include_root
    root = Location.create(:name => "HQ")
    assert_equal "HQ", root.location_string    
  end

  def test_not_include_root
    root = Soldier.create(:name => "President Paul")
    assert_equal "", root.chain_o_command
  end

  def test_two_breadcrumbs
    root = WebPage.create(:title => "Foo")
    child1 = root.children.create(:title => "Bar")
    child2 = child1.children.create(:title => "Baz")

    assert_equal "foo/bar/baz", child2.url
    assert_equal "Foo&nbsp;&gt;&nbsp;Bar&nbsp;&gt;&nbsp;Baz", child2.breadcrumbs
  end
end