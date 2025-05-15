import SwiftUI

struct PixabayImage: Decodable, Identifiable {
    let id: Int
    let webformatURL: String
}

struct PixabayResponse: Decodable {
    let hits: [PixabayImage]
}

struct ContentView: View {
    @State private var query = ""
    @State private var images: [PixabayImage] = []
    
    let apiKey = "50128400-fd734a0c5f16757b8d677e322"

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search...", text: $query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Go") {
                        print("버튼 클릭됨. 검색어: \(query)")
                        fetchImages()
                    }
                }
                .padding()

                if images.isEmpty {
                    Spacer()
                    Text("이미지가 없습니다.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(images) { image in
                        VStack {
                            Text("이미지 ID: \(image.id)")
                                .font(.caption)
                                .padding(.bottom, 5)
                            AsyncImage(url: URL(string: image.webformatURL)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                case .failure:
                                    Image(systemName: "photo")
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(height: 200)
                        }
                    }
                }
            }
            .navigationTitle("Pixabay Search")
        }
    }

    func fetchImages() {
        guard let url = URL(string:
            "https://pixabay.com/api/?key=\(apiKey)&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&image_type=photo"
        ) else {
            print("URL 생성 실패")
            return
        }

        print("요청 URL: \(url.absoluteString)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("네트워크 에러: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("데이터 없음")
                return
            }

            do {
                let result = try JSONDecoder().decode(PixabayResponse.self, from: data)
                DispatchQueue.main.async {
                    self.images = result.hits
                    print("이미지 \(result.hits.count)개 로드 완료")
                    for img in result.hits {
                        print("\(img.webformatURL)")
                    }
                }
            } catch {
                print("디코딩 실패: \(error.localizedDescription)")
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
