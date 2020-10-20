require "test_helper"

class TestModel1

  include RenderJsonRails::Concern
  render_json_config name: :mailbox,
                     except: [:account_id]
                    #  includes: {
                    #    last_emails: Mail::Email,
                    #  }

end

class RenderJsonRailsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil RenderJsonRails::VERSION
  end

  def test_it_does_something_useful
    # assert false
    # m1 = TestModel1.new

    out = TestModel1.render_json_options
    expected = {
      except: [:account_id],
      methods: nil,
    }
    assert_equal expected, out, "out: #{out}"


  end
end
