import UIKit
import FLCharts

class SellerChartCell: UICollectionViewCell {
    static let reuseId = "SellerChart"
    var card: FLCard! = nil
    
    func createDailyChart(data: [MultiPlotable]) {
        let chartData = FLChartData(title: "Просмотры", data: data, legendKeys: [Key(key: "Просмотры", color: .red)], unitOfMeasure: "")
        chartData.xAxisUnitOfMeasure = "Число"
        
        let chart = FLChart(data: chartData, type: .bar(highlightView: BarHighlightedView()))
        chart.shouldScroll = true
        
        setupCardView(chart: chart, showAverage: true)
    }
    
    
    func createSalesChart(data: [FLPiePlotable]) {
        let pieChart = FLPieChart(title: "Продажи", data: data, border: .full, animated: true)
        
        setupCardView(chart: pieChart, showAverage: false)
    }
    
    func createSalesLineChart(data: [MultiPlotable]) {
        let keys = [Key(key: "Выручка", color: .blue)]
        let chartData = FLChartData(title: "Продажи за месяц", data: data, legendKeys: keys, unitOfMeasure: "")
        let chart = FLChart(data: chartData, type: .line(config: FLLineConfig()))
        
        setupCardView(chart: chart, showAverage: false)
    }

    func setupCardView(chart: FLChart, showAverage: Bool) {
        guard card == nil else {
            return
        }
        
        let style = FLCardStyle(backgroundColor: .white, textColor: .black, cornerRadius: 15,
                                shadow: FLShadow(color: .black, radius: 1, opacity: 0.2))
        card = FLCard(chart: chart, style: style)
        card.showAverage = showAverage

        addSubview(card)
        card.snp.makeConstraints { make in
            make.center.equalTo(snp.center)
            make.height.equalTo(snp.height)
            make.width.equalTo(snp.width)
        }
    }
    
    func setupCardView(chart: FLPieChart, showAverage: Bool) {
        guard card == nil else {
            return
        }
        
        let style = FLCardStyle(backgroundColor: .white, textColor: .black, cornerRadius: 15,
                                shadow: FLShadow(color: .black, radius: 1, opacity: 0.2))
        card = FLCard(chart: chart, style: style)
        card.showAverage = showAverage

        addSubview(card)
        card.snp.makeConstraints { make in
            make.center.equalTo(snp.center)
            make.height.equalTo(snp.height)
            make.width.equalTo(snp.width)
        }
    }
    
    func statNotExist() {
        let label = UILabel(text: "Добавьте товары для просмотра функционала.",
                            font: Constants.Fonts.itemDescriptionFont,
                            textColor: .black)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        self.card = nil
    }
}
