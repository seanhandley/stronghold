require 'test_helper'

class TestConcernQuotaUsage < CleanTest
  def setup
    @quota = {
      "compute" => {
        "instances" => "100",
        "cores"     => "100",
        "ram"       => "512000"
      },
      "volume" => { 
        "volumes"   => "10",
        "snapshots" => "10",
        "gigabytes" => "10240"
      }
    }
    @project = Project.make! quota_set: @quota
  end

  def test_available_vcpus
    assert_equal 100, @project.available_vcpus
  end

  def test_available_ram
    assert_equal 512_000, @project.available_ram
  end

  def test_available_storage
    assert_equal 10_240, @project.available_storage
  end

  def test_used_percent
    @project.stub(:used_vcpus, 50) do
      @project.stub(:used_ram, 256_000) do
        @project.stub(:used_storage, 5120) do
          assert_equal 50, @project.total_used_as_percent
        end
      end
    end
  end
end