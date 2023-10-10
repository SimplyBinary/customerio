defmodule Customerio.TriggerTransactionalMessageTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  describe "Customerio::trigger_transactional_message" do
    test "Successful transactional message trigger" do
      ExVCR.Config.filter_request_headers("Authorization")

      use_cassette "trigger_transactional_message/pass" do
        assert {:ok, result} =
                 Customerio.trigger_transactional_message(
                   2,
                   %{message_data: %{title: "Transactional Message Test"}}
                 )

        assert "{\"id\":47}" == result
      end
    end
  end
end
