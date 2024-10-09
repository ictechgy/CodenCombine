//
//  UITableView+Combine.swift
//  CodenCombine
//
//  Created by JINHONG AN on 10/9/24.
//

import UIKit
import Combine

public extension UITableView {
    func items() -> Void {
        
    }
}

public extension Publisher {
    func bind<Element>(to binder: (UITableView, Array<Element>, IndexPath) -> UITableViewCell) {
        
    }
}

final class CombineUITableViewDataSourceProxy<ValueAccessibleSource: ValueAccessiblePublisher, Element>: NSObject, UITableViewDataSource where ValueAccessibleSource.Output == [Element] {
    private let canEditRowAt: ((UITableView, IndexPath) -> Bool)?
    private let canMoveRowAt: ((UITableView, IndexPath) -> Bool)?
    private let moveRowAtTo: ((UITableView, IndexPath, IndexPath) -> Void)?
    private let commitForRowAt: ((UITableView, UITableViewCell.EditingStyle, IndexPath) -> Void)?
    private let titleForHeaderInSection: ((UITableView, Int) -> String)?
    private let titleForFooterInSection: ((UITableView, Int) -> String)?
    private let sectionForSectionIndexTitleAt: ((UITableView, String, Int) -> Int)?
    private let numberOfRowsInSection: ((UITableView, Int) -> Int)?
    private let cellForRowAt: (UITableView, IndexPath) -> UITableViewCell
    private let numberOfSections: ((UITableView) -> Int)?
    private let sectionIndexTitles: ((UITableView) -> [String])?
    private let valueAccessiblePublisher: ValueAccessibleSource
    
    init(
        canEditRowAt: ((UITableView, IndexPath) -> Bool)?,
        canMoveRowAt: ((UITableView, IndexPath) -> Bool)?,
        moveRowAtTo: ((UITableView, IndexPath, IndexPath) -> Void)?,
        commitForRowAt: ((UITableView, UITableViewCell.EditingStyle, IndexPath) -> Void)?,
        titleForHeaderInSection: ((UITableView, Int) -> String)?,
        titleForFooterInSection: ((UITableView, Int) -> String)?,
        sectionForSectionIndexTitleAt: ((UITableView, String, Int) -> Int)?,
        numberOfRowsInSection: ((UITableView, Int) -> Int)?,
        cellForRowAt: @escaping (UITableView, IndexPath) -> UITableViewCell,
        numberOfSections: ((UITableView) -> Int)?,
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
        numberOfRowsInSection?(tableView, section) ?? valueAccessiblePublisher.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellForRowAt(tableView, indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        numberOfSections?(tableView) ?? 1
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        sectionIndexTitles?(tableView)
    }
}
