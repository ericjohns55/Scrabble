//
//  TileView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct RoundedCornerRect: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.size.width
        let height = rect.size.height

        let topLeftRadius = min(min(topLeft, height / 2), width / 2)
        let topRightRadius = min(min(topRight, height / 2), width / 2)
        let bottomLeftRadius = min(min(bottomLeft, height / 2), width / 2)
        let bottomRightRadius = min(min(bottomRight, height / 2), width / 2)

        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width - topRightRadius, y: 0))
        path.addArc(center: CGPoint(x: width - topRightRadius, y: topRightRadius), radius: topRightRadius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)

        path.addLine(to: CGPoint(x: width, y: height - bottomRightRadius))
        path.addArc(center: CGPoint(x: width - bottomRightRadius, y: height - bottomRightRadius), radius: bottomRightRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        path.addLine(to: CGPoint(x: bottomLeftRadius, y: height))
        path.addArc(center: CGPoint(x: bottomLeftRadius, y: height - bottomLeftRadius), radius: bottomLeftRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: topLeftRadius))
        path.addArc(center: CGPoint(x: topLeftRadius, y: topLeftRadius), radius: topLeftRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)

        path.closeSubpath()

        return path
    }
}


struct TileView: View {
    let tile: Tile
    let size: CGFloat
    
    let cornerRadius: CGFloat = 8
    
    static var inRenderMode: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            let notCommitted = tile.tileState != .committedToBoard
            
            let roundedRectangle = RoundedCornerRect(
                topLeft: tile.cornerRadii.topLeft ? 0 : cornerRadius,
                topRight: tile.cornerRadii.topRight ? 0 : cornerRadius,
                bottomLeft: tile.cornerRadii.bottomLeft ? 0 : cornerRadius,
                bottomRight: tile.cornerRadii.bottomRight ? 0 : cornerRadius)
            
            Text(tile.letter)
                .font(TileView.inRenderMode ? .title.bold() : .title2.bold())
                .foregroundStyle(notCommitted ? Color.black : Color.white)
                .frame(width: size, height: size)
                .background(notCommitted ? Color.yellow : Color.gray)
                .clipShape(roundedRectangle)
                .overlay(roundedRectangle.stroke(Color.black, lineWidth: 1))
            
            if (!TileView.inRenderMode) {
                Text("\(tile.points)")
                    .font(.caption2)
                    .foregroundStyle(notCommitted ? Color.black : Color.white)
                    .padding(4)
            }
        }
    }
}
