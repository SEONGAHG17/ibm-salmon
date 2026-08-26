import asyncio

from main import ChatRequest, chat_with_watsonx


async def main():
    result = await chat_with_watsonx(
        ChatRequest(
            message="테스트야. 저장된 스크린샷 분석 결과가 없으면 없다고 짧게 답해줘.",
            user_id="default_user",
        )
    )
    data = result.model_dump()

    print(f"status: {data['status']}")
    print(f"provider: {data['provider']}")
    print(f"model: {data['model']}")
    print(f"notice: {data.get('notice')}")
    print(f"reply: {data['reply']}")
    print(f"citations_count: {len(data['citations'])}")


if __name__ == "__main__":
    asyncio.run(main())
