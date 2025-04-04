/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include <QtCore/QFile>
#include <QtCore/QObject>

/// This class mimics QTemporaryFile. We have our own implementation due to the fact that
/// QTemporaryFile implemenation differs cross platform making it unusable for our use-case.
/// Look for bug reports on QTemporaryFile keeping the file locked for details.
class QGCTemporaryFile : public QFile
{
    Q_OBJECT

public:
	/// Creates a new temp file object. QGC temp files are always created in the QStandardPaths::TempLocation directory.
	///		@param template Template for file name following QTemporaryFile rules. Template should NOT include directory path, only file name.
    explicit QGCTemporaryFile(const QString &fileTemplate, QObject *parent = nullptr);
    ~QGCTemporaryFile();

    bool open(OpenMode openMode = ReadWrite);

    void setAutoRemove(bool autoRemove) { _autoRemove = autoRemove; }

private:
    static QString _newTempFileFullyQualifiedName(const QString &fileTemplate);

    const QString _template;
    bool _autoRemove = false;
};
