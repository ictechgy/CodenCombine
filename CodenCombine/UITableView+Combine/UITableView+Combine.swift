//
//  UITableView+Combine.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/9/24.
//

import UIKit
import Combine

public extension UITableView {
    func items<Source: ValueAccessiblePublisher, Element>(_ source: Source) -> (@escaping (UITableView, IndexPath, Source.Output) -> UITableViewCell) -> Cancellable where Source.Output == [Element], Source.Failure == Never {
        { cellBuilder in
            
            let dataSoruceProxy: CombineUITableViewDataSourceProxy<Source, Element>
            if let dataSource = self.dataSource, type(of: dataSource) != CombineUITableViewDataSourceProxy<Source, Element>.self {
                fatalError("이미 다른 dataSource가 설정되어있습니다.")
                
            } else if let aleadyExistingProxy = self.dataSource as? CombineUITableViewDataSourceProxy<Source, Element> {
                dataSoruceProxy = aleadyExistingProxy
                dataSoruceProxy.cellForRowAt = cellBuilder
            } else {
                dataSoruceProxy = CombineUITableViewDataSourceProxy(
                    canEditRowAt: nil,
                    canMoveRowAt: nil,
                    moveRowAtTo: nil,
                    commitForRowAt: nil,
                    titleForHeaderInSection: nil,
                    titleForFooterInSection: nil,
                    sectionForSectionIndexTitleAt: nil,
                    numberOfRowsInSection: nil,
                    cellForRowAt: cellBuilder,
                    numberOfSections: nil,
                    sectionIndexTitles: nil,
                    valueAccessiblePublisher: source
                )
                self.dataSource = dataSoruceProxy
            }
            
            // 최종적으로는 아래가 구독되는 형태
            return source
                .sink { value in
                    
                }
        }
    }
}

public extension ValueAccessiblePublisher {
    typealias CellBuilder = (UITableView, IndexPath, Output) -> UITableViewCell
    
    func bind(to binder: (Self) -> (CellBuilder) -> Cancellable, cellBuilder: CellBuilder) -> Cancellable {
        binder(self)(cellBuilder)
    }
}

final class CombineUITableViewDataSourceProxy<ValueAccessibleSource: ValueAccessiblePublisher, Element>: NSObject, UITableViewDataSource where ValueAccessibleSource.Output == [Element] {
    fileprivate var canEditRowAt: ((UITableView, IndexPath) -> Bool)?
    fileprivate var canMoveRowAt: ((UITableView, IndexPath) -> Bool)?
    fileprivate var moveRowAtTo: ((UITableView, IndexPath, IndexPath) -> Void)?
    fileprivate var commitForRowAt: ((UITableView, UITableViewCell.EditingStyle, IndexPath) -> Void)?
    fileprivate var titleForHeaderInSection: ((UITableView, Int) -> String)?
    fileprivate var titleForFooterInSection: ((UITableView, Int) -> String)?
    fileprivate var sectionForSectionIndexTitleAt: ((UITableView, String, Int) -> Int)?
    fileprivate var numberOfRowsInSection: ((UITableView, Int, [Element]) -> Int)?
    fileprivate var cellForRowAt: (UITableView, IndexPath, [Element]) -> UITableViewCell
    fileprivate var numberOfSections: ((UITableView, [Element]) -> Int)?
    fileprivate var sectionIndexTitles: ((UITableView) -> [String])?
    private let valueAccessiblePublisher: ValueAccessibleSource
    
    init(
        canEditRowAt: ((UITableView, IndexPath) -> Bool)?,
        canMoveRowAt: ((UITableView, IndexPath) -> Bool)?,
        moveRowAtTo: ((UITableView, IndexPath, IndexPath) -> Void)?,
        commitForRowAt: ((UITableView, UITableViewCell.EditingStyle, IndexPath) -> Void)?,
        titleForHeaderInSection: ((UITableView, Int) -> String)?,
        titleForFooterInSection: ((UITableView, Int) -> String)?,
        sectionForSectionIndexTitleAt: ((UITableView, String, Int) -> Int)?,
        numberOfRowsInSection: ((UITableView, Int, [Element]) -> Int)?,
        cellForRowAt: @escaping (UITableView, IndexPath, [Element]) -> UITableViewCell,
        numberOfSections: ((UITableView, [Element]) -> Int)?,
        sectionIndexTitles: ((UITableView) -> [String])?,
        valueAccessiblePublisher: ValueAccessibleSource
    ) {
        self.canEditRowAt = canEditRowAt
        self.canMoveRowAt = canMoveRowAt
        self.moveRowAtTo = moveRowAtTo
        self.commitForRowAt = commitForRowAt
        self.titleForHeaderInSection = titleForHeaderInSection
        self.titleForFooterInSection = titleForFooterInSection
        self.sectionForSectionIndexTitleAt = sectionForSectionIndexTitleAt
        self.numberOfRowsInSection = numberOfRowsInSection
        self.cellForRowAt = cellForRowAt
        self.numberOfSections = numberOfSections
        self.sectionIndexTitles = sectionIndexTitles
        self.valueAccessiblePublisher = valueAccessiblePublisher
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        canEditRowAt?(tableView, indexPath) ?? false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        canMoveRowAt?(tableView, indexPath) ?? false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveRowAtTo?(tableView, sourceIndexPath, destinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        commitForRowAt?(tableView, editingStyle, indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        titleForFooterInSection?(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        titleForHeaderInSection?(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        sectionForSectionIndexTitleAt?(tableView, title, index) ?? index
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRowsInSection?(tableView, section, valueAccessiblePublisher.value) ?? valueAccessiblePublisher.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellForRowAt(tableView, indexPath, valueAccessiblePublisher.value)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        numberOfSections?(tableView, valueAccessiblePublisher.value) ?? 1
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        sectionIndexTitles?(tableView)
    }
}
