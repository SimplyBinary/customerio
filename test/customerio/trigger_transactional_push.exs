defmodule Customerio.TriggerTransactionalPushTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  describe "Customerio::trigger_transactional_push" do
    test "Successful transactional push trigger" do
      ExVCR.Config.filter_request_headers("Authorization")

      use_cassette "trigger_transactional_push/pass" do
        assert {:ok, result} =
                 Customerio.trigger_transactional_push(
                   3,
                   %{data: %{title: "Transactional Push Test"}}
                 )

        assert "{\"id\":47}" == result
      end
    end
  end
end
