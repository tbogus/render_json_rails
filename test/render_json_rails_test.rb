require "test_helper"

class TestModel1

  include RenderJsonRails::Concern
  render_json_config name: :model1,
                     except: [:account_id]
                    #  includes: {
                    #    last_emails: Mail::Email,
                    #  }

end

class DefaultFieldsModel

  include RenderJsonRails::Concern
  render_json_config name: :default_fields_model,
                     default_fields: [:id, :account_id, :name],
                     except: [:account_id]

end

class RenderJsonRailsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil RenderJsonRails::VERSION
  end

  def test_model1
    out = TestModel1.render_json_options()
    expected = { except: [:account_id] }
    assert_equal expected, out, "out: #{out}"

    out = TestModel1.render_json_options(fields: { "model1" => "id,account_id,name" })
    expected = { only: [:id, :name] }
    assert_equal expected, out, "out: #{out}"
  end

  def test_default_fields_model
    out = DefaultFieldsModel.render_json_options()
    expected = { only: [:id, :name] }
    assert_equal expected, out, "out: #{out}"

    out = DefaultFieldsModel.render_json_options(fields: { "default_fields_model" => "id,account_id,kind,user"})
    expected = { only: [:id, :kind, :user] }
    assert_equal expected, out, "out: #{out}"
  end
end
