//
//  Home.swift
//  UI-775
//
//  Created by nyannyan0328 on 2022/10/21.
//SCROLLER

import SwiftUI

struct Home: View {
    @State var characters : [Character] = []
    
    @State var currentCharacter : Character = Character(value: "")
    
    @State var startOffset : CGFloat = 0
    
    @State var scrollHeight : CGFloat = 0
    @State var indicatorOfffset : CGFloat = 0
    
    @State var hideIndicatorLable : Bool = false
    
     @State var timeOut  : CGFloat = 0
    var body: some View {
        NavigationStack{
            
            GeometryReader{
                
                let size = $0.size
             
                ScrollViewReader { proxy in
                    
                    ScrollView(.vertical,showsIndicators: false){
                        
                        VStack(spacing: 0) {
                            
                            
                            ForEach(characters){character in
                                
                                ContactCharacter(character: character)
                                    .id(character.index)
                                
                            }
                            
                            
                        }
                        .padding(.top)
                        .padding(15)
                        .offset { rect in
                            
                            if hideIndicatorLable && rect.minY < 0{
                                
                                timeOut = 0
                                hideIndicatorLable = false
                            }
                            
                            let rectHeight = rect.height
                            let viewHeight = size.height + (startOffset / 2)
                            
                            let scrollHeight = (viewHeight / rectHeight) * viewHeight
                            
                            self.scrollHeight = scrollHeight
                            
                            let progress = rect.minY / (rectHeight - size.height)
                            indicatorOfffset = -progress * (size.height - scrollHeight)
                            
                            
                            
                        }
                        
                    }
                }
                .coordinateSpace(name: "SCROLLER")
                .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
                .overlay(alignment: .topTrailing) {
                    
                    Rectangle()
                        .fill(.clear)
                         .frame(width: 2,height: scrollHeight)
                         .offset(y:indicatorOfffset)
                         .overlay(alignment: .topTrailing) {
                             
                             Image(systemName: "bubble.middle.bottom.fill")
                                 .resizable()
                                 .renderingMode(.template)
                                 .aspectRatio(contentMode: .fill)
                                 .frame(width: 45,height: 45)
                                 .foregroundStyle(.ultraThinMaterial)
                                 .rotationEffect(.init(degrees: -90))
                                 .overlay(content: {
                                     
                                     Text(currentCharacter.value)
                                         .font(.largeTitle.bold())
                                         .foregroundColor(.white)
                                         .offset(x:-5)
                                 })
                               
                                 .environment(\.colorScheme, .dark)
                                 .offset(x:hideIndicatorLable || currentCharacter.value == "" ? 65 : 0)
                                 .animation(.interactiveSpring(response: 1.1,dampingFraction: 0.85,blendDuration: 0.85), value: hideIndicatorLable || currentCharacter.value == "")
                             
                         }
                }
             
                
            }
            .navigationTitle("Home")
        }
        .onAppear{
         
            characters = fetchCharacters()
            
        }
        .offset { rect in
            
            if  startOffset != rect.minY{
                
                startOffset = rect.minY
            }
        }
        .onReceive(Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()) { _ in
            
            if timeOut < 0.3{
                timeOut += 0.01
            }
            
            if !hideIndicatorLable{
                
                hideIndicatorLable = true
            }
            
        }
    }
    @ViewBuilder
    func ContactCharacter(character : Character)->some View{
        
        VStack(alignment:.leading,spacing: 10){
            
            Text(character.value)
                .font(.largeTitle.bold())
            
            ForEach(1...5 ,id:\.self){index in
                
                HStack(spacing: 15) {
                    Circle()
                        .fill(character.color)
                         .frame(width: 45,height: 45)
                    
                
                
                    
                    VStack(alignment:.leading,spacing: 10){
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(character.color.gradient)
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(character.color.gradient)
                            .frame(height: 20)
                            .padding(.trailing,100)
                        
                        
                    }
                }
            }
        
            
        }
        .offset { rect in
            
            if characters.indices.contains(character.index){
                
                characters[character.index].rect = rect
                
            }
            
            if let last = characters.last(where: { char in
                
                char.rect.minY < 0
            }),last.id != currentCharacter.id {
                
                currentCharacter = last
                
            }
            
        }
        
    }
    
    func fetchCharacters()->[Character]{
        
        let alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var charcters : [Character] = []
        
        charcters = alphabets.compactMap({ character -> Character? in
            
           return Character(value: String(character))
            
        })
        
        let colors : [Color] = [.red,.yellow,.gray,.green,.orange,.purple,.indigo,.blue,.pink]
        
        for index in charcters.indices{
            
            charcters[index].index = index
            charcters[index].color = colors.randomElement()!
        }
        
    
        
        return charcters
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View{
    
    @ViewBuilder
    func offset(competion : @escaping(CGRect) -> ()) -> some View{
        
        self
            .overlay {
                GeometryReader{
                    
                    let rect = $0.frame(in: .named("SCROLLER"))
                    
                    Color.clear
                        .preference(key :OffsetKey.self, value: rect)
                        .onPreferenceChange(OffsetKey.self) { value in
                            
                            competion(value)
                        }
                    
                    
                    
                }
            }
        
        
        
    }
    
}

struct OffsetKey : PreferenceKey{
    
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
