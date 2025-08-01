/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#pragma once

#include <QtCore/QAbstractListModel>
#include <QtCore/QLoggingCategory>
#include <QtQmlIntegration/QtQmlIntegration>

Q_DECLARE_LOGGING_CATEGORY(QmlObjectListModelLog)

class QmlObjectListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")
public:
    QmlObjectListModel(QObject* parent = nullptr);
    ~QmlObjectListModel() override;
    
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    
    /// Returns true if any of the items in the list are dirty. Requires each object to have
    /// a dirty property and dirtyChanged signal.
    Q_PROPERTY(bool dirty READ dirty WRITE setDirty NOTIFY dirtyChanged)

    Q_INVOKABLE QObject* get(int index);
    const QObject *get(int index) const;

    // Property accessors
    
    int         count               () const;
    bool        dirty               () const { return _dirty; }

    void        setDirty            (bool dirty);
    void        append              (QObject* object);
    void        append              (QList<QObject*> objects);
    QObjectList swapObjectList      (const QObjectList& newlist);
    void        clear               ();
    QObject*    removeAt            (int i);
    QObject*    removeOne           (const QObject* object) { return removeAt(indexOf(object)); }
    void        insert              (int i, QObject* object);
    void        insert              (int i, QList<QObject*> objects);
    bool        contains            (const QObject* object) { return _objectList.indexOf(object) != -1; }
    int         indexOf             (const QObject* object) { return _objectList.indexOf(object); }

    /// Moves an item to a new position
    void move(int from, int to);

    QObject*    operator[]          (int i);
    const QObject* operator[]       (int i) const;
    template<class T> T value       (int index) const { return qobject_cast<T>(_objectList[index]); }
    QList<QObject*>* objectList     () { return &_objectList; }

    /// Calls deleteLater on all items and this itself.
    void deleteListAndContents      ();

    /// Clears the list and calls deleteLater on each entry
    void clearAndDeleteContents     ();

    /// These methods handling nesting a begin/end pairs. Such that only the outermost
    /// beginResetModel/endResetModel pair will emit modelReset.
    void beginResetModel            ();
    void endResetModel              ();

signals:
    void countChanged               (int count);
    void dirtyChanged               (bool dirtyChanged);
    
private slots:
    void _childDirtyChanged         (bool dirty);
    
private:
    // Overrides from QAbstractListModel
    int         rowCount    (const QModelIndex & parent = QModelIndex()) const override;
    QVariant    data        (const QModelIndex & index, int role = Qt::DisplayRole) const override;
    bool        insertRows  (int position, int rows, const QModelIndex &index = QModelIndex()) override;
    bool        removeRows  (int position, int rows, const QModelIndex &index = QModelIndex()) override;
    bool        setData     (const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QHash<int, QByteArray> roleNames(void) const override;

private:
    QList<QObject*> _objectList;
    
    bool _dirty;
    bool _skipDirtyFirstItem;
    uint _resetModelNestingCount = 0;
        
    static constexpr int ObjectRole = Qt::UserRole;
    static constexpr int TextRole = Qt::UserRole + 1;
};
