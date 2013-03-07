require File.expand_path('../helper', __FILE__)

class TestMab < ActionDispatch::IntegrationTest
  test "normal view" do
    get "application/normal"
    assert_response :success
    assert_template "application/normal"
    assert_template "layouts/application"
    assert_html "<h1>Hello Mab!</h1>"
  end

  test "no layout" do
    get "application/no_layout"
    assert_response :success
    assert_template "application/normal"
    assert_equal "<h1>Hello Mab!</h1>", @response.body
  end

  test "variables" do
    get "application/variables"
    assert_response :success
    assert_template "application/variables"
    assert_template "layouts/application"
    assert_html "<h1>Hello world!</h1>"
  end

  test "content for" do
    get "application/content_for"
    assert_response :success
    assert_template "application/content_for"
    assert_template "layouts/application"
    assert_html "<h2>Sub</h2>", :heading => "<h1>Heading</h1>"
  end

  def assert_html(expected, options = {})
    expected = "<!DOCTYPE html><html><head><title>Dummy</title></head><body>#{options[:heading]}<div class=\"content\">#{expected}</div></body></html>" unless options[:skip_layout]
    assert_equal expected, @response.body
  end
end

